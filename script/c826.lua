-- Quick Effect: Banish from GY to Xyz or Link Summon a DARK monster using your field, must include a Phantom Knights
function s.qscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

function s.qsop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsMainPhase() then return end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if not g:IsExists(Card.IsSetCard,1,nil,0x10db) then return end -- require 1 Phantom Knights

    local xyz_list=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
    local link_list=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_EXTRA,0,nil,g)

    local canXyz=#xyz_list>0
    local canLink=#link_list>0
    if not canXyz and not canLink then return end

    local opt=0
    if canXyz and canLink then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 0 = Xyz, 1 = Link
    elseif canXyz then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end

    if opt==0 then
        -- Perform Xyz Summon
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=xyz_list:Select(tp,1,1,nil):GetFirst()
        if not sc then return end
        local mg=g:Filter(Card.IsCanBeXyzMaterial,nil,sc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local mat=mg:Select(tp,sc:GetOverlayCount(),sc:GetOverlayCount(),nil)
        if #mat==0 then return end
        Duel.XyzSummon(tp,sc,mat)
    else
        -- Perform Link Summon
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=link_list:Select(tp,1,1,nil):GetFirst()
        if not sc then return end
        local mg=g:Filter(Card.IsCanBeLinkMaterial,nil,sc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
        local min,max=sc:GetLink(),sc:GetLink()
        local mat=aux.SelectUnselectGroup(mg,e,tp,min,max,s.linkcheck,1,tp,HINTMSG_LMATERIAL)
        if #mat==0 then return end
        Duel.LinkSummon(tp,sc,mat)
    end
end

function s.xyzfilter(c,mg)
    return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(nil,mg)
end

function s.linkfilter(c,mg)
    return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLinkSummonable(nil,mg)
end

function s.linkcheck(sg,e,tp,mg)
    return sg:IsExists(Card.IsSetCard,1,nil,0x10db)
end
