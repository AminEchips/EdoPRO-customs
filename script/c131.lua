--Magical Star Illusion
local s,id=GetID()
function s.initial_effect(c)
    -- Always treated as "Pendulumgraph"
    local e0a=Effect.CreateEffect(c)
    e0a:SetType(EFFECT_TYPE_SINGLE)
    e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0a:SetCode(EFFECT_ADD_SETCODE)
    e0a:SetRange(LOCATION_ALL)
    e0a:SetValue(0x254)
    c:RegisterEffect(e0a)

    -- Quick-play activation: Boost ATK of all monsters you control by 500 for each card in your Pendulum Zones
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_DAMAGE_STEP)
    e1:SetCondition(aux.StatChangeDamageStepCondition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- GY effect: During End Phase, if a Spellcaster left your field by opponent's effect this turn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- Apply ATK boost based on Pendulum Zone occupancy
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local pzct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_PZONE,0,nil)
    if pzct==0 then return end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        e1:SetValue(pzct*500)
        tc:RegisterEffect(e1)
    end
end

-- Graveyard condition: a Spellcaster you controlled left field due to opponent's effect this turn
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,0,nil,e)
    return g:GetCount()>0
end
function s.cfilter(c,e)
    return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(e:GetHandlerPlayer())
        and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsRace(RACE_SPELLCASTER)
end

-- Graveyard target and operation
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thfilter(c)
    return c:IsRace(RACE_SPELLCASTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    local op=0
    if tc:IsAbleToHand() and tc:IsAbleToGrave() then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif tc:IsAbleToHand() then
        op=0
    else
        op=1
    end
    if op==0 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end
