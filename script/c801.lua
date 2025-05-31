--Raidraptor - Rebellion Lanius
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Tribute to search + level mod
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Effect 2: Attach from GY/banished when Rebellion Xyz is Special Summoned by card effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
    e2:SetCountLimit(1,{id,1}) -- Once per duel
    e2:SetCondition(s.attachcon)
    e2:SetTarget(s.attachtg)
    e2:SetOperation(s.attachop)
    c:RegisterEffect(e2)
end
s.listed_series={0xba,0xdb,0x13b}

-- Cost and search effect
function s.costfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,e:GetHandler())
    Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
    return (c:IsSetCard(0xba) or c:IsSetCard(0xdb)) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        local val = (op==0) and 1 or -1
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Rebellion Xyz summon detection (by any card effect)
function s.rebellionfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x13b) and c:IsType(TYPE_XYZ)
        and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetSummonPlayer()==tp
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:IsActivated() and eg:IsExists(s.rebellionfilter,1,nil,tp)
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
        -- Then destroy 1 card on field
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end
