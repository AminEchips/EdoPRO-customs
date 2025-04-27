--Blackwing Tamer - Darkage Master
local s,id=GetID()
s.listed_names={9012916} -- Black-Winged Dragon
s.listed_series={0x33} -- Blackwing archetype

function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x33),1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),1,99)
    c:EnableReviveLimit()
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- Register Synchro Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetCondition(s.regcon)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- Continuous ATK gain
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Battle and Effect protection
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.indcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e3)

    -- Quick Effect: Negate Spell/Trap and add 2 Black Feather Counters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_NEGATE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.negcon)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)

    -- Board wipe: Remove 4 Black Feather Counters from anywhere
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+100)
    e5:SetCost(s.descost)
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
end

-- Synchro Summon registration
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end

-- ATK gain
function s.atkval(e,c)
    if c:GetFlagEffect(id)>0 then
        return c:GetCounter(COUNTER_FEATHER)*700
    else
        return 0
    end
end

-- Protection if Synchro Summoned
function s.indcon(e)
    return e:GetHandler():GetFlagEffect(id)>0
end

-- Condition to check for Black-Winged Dragon or anything that lists it
function s.bwdcheck(c)
    return c:IsFaceup() and (c:IsCode(9012916) or c:ListsCode(9012916))
end

-- Negate Spell/Trap
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev)
        and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
        and Duel.IsExistingMatchingCard(s.bwdcheck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local c=e:GetHandler()
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            c:AddCounter(COUNTER_FEATHER,2)
        end
    end
end

-- Board wipe: remove 4 Black Feather Counters from controller's field
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_FEATHER,4,REASON_COST) end
    Duel.RemoveCounter(tp,1,0,COUNTER_FEATHER,4,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
