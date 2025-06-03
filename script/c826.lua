--The Phantom Knights of Deathscythe
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Send this card from hand/field to GY; Special Summon 2 DARK monsters from hand/PZONE
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Effect 2: Banish from GY to Xyz or Link Summon using "Phantom Knights"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.qscon)
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.qsop)
    c:RegisterEffect(e2)
end

--===== Effect 1: Summon DARK from hand/PZONE =====--
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_PZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,nil,e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,2,nil)
    for tc in sg:Iter() do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetLabelObject(tc)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end
    end
    Duel.SpecialSummonComplete()
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:IsControler(tp) and tc:IsOnField() then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

--===== Effect 2: Quick GY effect - Xyz or Link Summon =====--
function s.qscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

function s.qsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if not g:IsExists(Card.IsSetCard,1,nil,0x10db) then return end

    local xyz_list=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
    local link_list=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_EXTRA,0,nil,g)

    local canXyz=#xyz_list>0
    local canLink=#link_list>0
    if not canXyz and not canLink then return end

    local opt=0
    if canXyz and canLink then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0 = Xyz, 1 = Link
    elseif canXyz then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2))
    else
        opt=Duel.SelectOption(tp,aux.Stringid(id,3))+1
    end

    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=xyz_list:Select(tp,1,1,nil):GetFirst()
        if not sc then return end
        local mg=g:Filter(Card.IsCanBeXyzMaterial,nil,sc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local mat=mg:Select(tp,sc:GetOverlayCount(),sc:GetOverlayCount(),nil)
        if #mat==0 then return end
        Duel.XyzSummon(tp,sc,mat)
    else
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
