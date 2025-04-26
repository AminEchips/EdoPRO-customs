--Blackwing - Leveche the Dashing
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33}
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x33),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Special Summon Winged Beast Tuner from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    -- Wedge Counter when attack declared
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.ctcon)
    e2:SetOperation(s.ctop)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)
    -- Banish from GY to change Level
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_LVCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMING_MAIN_END)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.lvtg)
    e3:SetOperation(s.lvop)
    e3:SetCountLimit(1,{id,2})
    c:RegisterEffect(e3)
end

----------------------------------------------------------
-- (1) Special Summon Tuner from GY
----------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- Negate effects
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2,true)
        end
    end
end

----------------------------------------------------------
-- (2) Place Wedge Counters
----------------------------------------------------------
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        tc:AddCounter(0x1106,1)
    end
end

----------------------------------------------------------
-- (3) Level Change (GY)
----------------------------------------------------------
function s.lvfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
    local lv=Duel.AnnounceLevel(tp,1,3)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
        tc:RegisterEffect(e1)
    end
end
