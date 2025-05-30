--Blackwing - Higure the Moonshade
local s,id=GetID()
function s.initial_effect(c)
    -- Enable Wedge Counters
    c:EnableCounterPermit(0x1002)

    -- Synchro Summon Procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Add "Black Souls Whirlwind" to hand on Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Quick Effect: Target 1 you control + 1 with Wedge Counter, destroy both
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- End Phase: Permanently negate monsters with Wedge Counters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.listed_names={621} -- Black Souls Whirlwind
s.listed_series={0x33} -- Blackwing

-----------------------------------------------------------
-- (1) Add "Black Souls Whirlwind" to hand
-----------------------------------------------------------
function s.thfilter(c)
    return c:IsCode(621) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-----------------------------------------------------------
-- (2) Quick Effect: Target 1 you control + 1 with Wedge Counter, destroy both
-----------------------------------------------------------
function s.wedgefilter(c)
    return c:IsFaceup() and c:GetCounter(0x1002)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingTarget(s.wedgefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,s.wedgefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not g then return end
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>0 then
        Duel.Destroy(sg,REASON_EFFECT)
    end
end

-----------------------------------------------------------
-- (3) End Phase: Permanently negate monsters with Wedge Counters
-----------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp
end
function s.negfilter(c)
    return c:IsFaceup() and c:GetCounter(0x1002)>0 and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroupCount(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>0 end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        -- Permanent negate
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end
