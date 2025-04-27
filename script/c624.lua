--Blackwing - Flock
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Place Wedge Counters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- GY Effect: Search + Normal Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={0x33}
s.counter_place_list={0x1002} -- Wedge Counters

-------------------------------------------------------
-- Activation: Place counters
-------------------------------------------------------
function s.cfilter(c)
    return c:IsSetCard(0x33) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        tc:AddCounter(0x1002,1)
    end
end

-------------------------------------------------------
-- GY Effect: Search + Summon
-------------------------------------------------------
function s.cfilter2(c,tp)
    return c:IsPreviousControler(tp) and c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.thfilter(c,atk)
    return c:IsSetCard(0x33) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local maxatk=0
    for tc in aux.Next(eg) do
        if s.cfilter2(tc,tp) and tc:GetAttack()>maxatk then
            maxatk=tc:GetAttack()
        end
    end
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,maxatk) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local maxatk=0
    for tc in aux.Next(eg) do
        if s.cfilter2(tc,tp) and tc:GetAttack()>maxatk then
            maxatk=tc:GetAttack()
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,maxatk)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.BreakEffect()
        local sg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND,0,1,1,nil,true,nil)
        if #sg>0 then
            Duel.Summon(tp,sg:GetFirst(),true,nil)
        end
    end
end
