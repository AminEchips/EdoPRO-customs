-- Effect 2: Attach from GY or banished when a "Rebellion" Xyz is Special Summoned by a Spell Effect
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    -- Must be caused by a Spell Card’s effect
    return re and re:IsActiveType(TYPE_SPELL)
        and eg:IsExists(s.rebellionfilter,1,nil,tp)
end

function s.rebellionfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x13b) and c:IsType(TYPE_XYZ)
        and c:GetSummonPlayer()==tp and c:GetSummonType()==SUMMON_TYPE_SPECIAL
        and c:IsLocation(LOCATION_MZONE)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.rebellionfilter(chkc,tp) end
    if chk==0 then return eg:IsExists(s.rebellionfilter,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=eg:FilterSelect(tp,s.rebellionfilter,1,1,nil,tp)
    Duel.SetTargetCard(g)
    if e:GetHandler():IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
    end
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(tc,Group.FromCards(c))
        -- Destroy 1 card
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end
