--Black-Winged Full Moon Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Allow Black Feather Counters
    c:EnableCounterPermit(0x1002)

    -- Synchro Summon Procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    -- Place 1 Black Feather Counter when a Synchro Monster is Summoned
    local e1=Effect.CreateEffect(c)
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

    -- Cannot be destroyed by battle if it has 3 or more counters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Special Summon itself + recover LP
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
s.counter_list={0x1002}
s.listed_series={0x33}

-------------------------------------------------------
-- Place Counter when a Synchro Monster Summoned
-------------------------------------------------------
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    for tc in aux.Next(eg) do
        if tc:IsSummonType(SUMMON_TYPE_SYNCHRO) then
            if c:IsFaceup() and c:IsRelateToEffect(e) then
                c:AddCounter(0x1002,1)
            end
            -- Only add once per monster (even if multiple summoned)
        end
    end
end

-------------------------------------------------------
-- ATK Boost
-------------------------------------------------------
function s.atkval(e,c)
    return c:GetCounter(0x1002)*700
end

-------------------------------------------------------
-- Battle Protection if 3 or more counters
-------------------------------------------------------
function s.indcon(e)
    return e:GetHandler():GetCounter(0x1002)>=3
end

-------------------------------------------------------
-- Revive + Gain LP
-------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        local ct=c:GetCounter(0x1002)
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and ct>0 then
            Duel.Recover(tp,ct*700,REASON_EFFECT)
        end
    end
end
