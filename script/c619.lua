--Black-Winged Full Moon Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Allow Black Feather Counters
    c:EnableCounterPermit(COUNTER_FEATHER)

    -- Synchro Summon Procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Place 1 Black Feather Counter when a monster is Synchro Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    -- ATK gain for each Black Feather Counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by battle if 3 or more Black Feather Counters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Store the number of counters when it leaves
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_LEAVE_FIELD_P)
    e4:SetOperation(s.storeop)
    c:RegisterEffect(e4)

    -- Special Summon itself + Recover based on stored counters
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end
s.listed_series={0x33}

-------------------------------------------------------
-- Place Counter when Synchro Summon happens
-------------------------------------------------------
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SYNCHRO) then
        e:GetHandler():AddCounter(COUNTER_FEATHER,1)
    end
end

-------------------------------------------------------
-- ATK Boost
-------------------------------------------------------
function s.atkval(e,c)
    return c:GetCounter(COUNTER_FEATHER)*700
end

-------------------------------------------------------
-- Battle Protection if 3+ counters
-------------------------------------------------------
function s.indcon(e)
    return e:GetHandler():GetCounter(COUNTER_FEATHER)>=3
end

-------------------------------------------------------
-- Store the counter amount before leaving the field
-------------------------------------------------------
function s.storeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:SetTurnCounter(c:GetCounter(COUNTER_FEATHER))
end

-------------------------------------------------------
-- Revive itself + recover LP
-------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetTurnCounter()>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,c:GetTurnCounter()*700)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetTurnCounter()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and ct>0 then
        Duel.Recover(tp,ct*700,REASON_EFFECT)
    end
end
