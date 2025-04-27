--Blackwing Tamer - Darkage Master
local s,id=GetID()
s.counter_list={0x1002} -- Black Feather Counter
s.listed_names={9012916} -- Black-Winged Dragon
s.listed_series={0x33} -- Blackwing archetype

function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x33),1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),1,99)
    c:EnableReviveLimit()

    -- Flag when Synchro Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetCondition(s.regcon)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- Gains ATK per Black Feather Counter
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Cannot be destroyed by battle or card effects
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

    -- Quick Effect: Negate Spell/Trap and place 2 Black Feather Counters
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

    -- Remove 4 counters from itself to destroy opponent's field
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

----------------------------------------------------------
-- (Internal) Register Synchro Summon flag
----------------------------------------------------------
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end

----------------------------------------------------------
-- (Continuous) ATK boost only if properly Synchro Summoned
----------------------------------------------------------
function s.atkval(e,c)
    if c:GetFlagEffect(id)>0 then
        return c:GetCounter(0x1002)*700
    else
        return 0
    end
end

----------------------------------------------------------
-- (Continuous) Indestructibility only if properly Synchro Summoned
----------------------------------------------------------
function s.indcon(e)
    return e:GetHandler():GetFlagEffect(id)>0
end

----------------------------------------------------------
-- (Quick Effect) Negate Spell/Trap and place 2 Black Feather Counters
----------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.IsChainNegatable(ev)
        and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
        and (Duel.IsExistingMatchingCard(s.bwdcheck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c)
             or Duel.IsExistingMatchingCard(s.bwdcheck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil))
end
function s.bwdcheck(c)
    return c:IsFaceup() and (c:IsCode(9012916) or c:ListsCode(9012916))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            c:AddCounter(0x1002,2) -- Add 2 counters now
        end
    end
end

----------------------------------------------------------
-- (Ignition Effect) Remove 4 counters from itself: destroy opponent's field
----------------------------------------------------------
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetCounter(0x1002)>=4 end
    c:RemoveCounter(tp,0x1002,4,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
