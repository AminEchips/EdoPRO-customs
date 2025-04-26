--Assault Blackwing - Kuniyoshi the White Rainbow
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33}
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Become Tuner if Synchro Summoned using a Blackwing
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.tncon)
    e1:SetValue(TYPE_TUNER)
    c:RegisterEffect(e1)
    -- Discard 1 Blackwing to activate 1 effect (each once)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,id) -- Up to 2 uses per turn
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

----------------------------------------------------------
-- Become Tuner condition
----------------------------------------------------------
function s.tncon(e)
    local c=e:GetHandler()
    local sumtype=c:GetSummonType()
    return sumtype==SUMMON_TYPE_SYNCHRO and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x33)
end

----------------------------------------------------------
-- Discard cost
----------------------------------------------------------
function s.costfilter(c)
    return c:IsSetCard(0x33) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

----------------------------------------------------------
-- Target
----------------------------------------------------------
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.GetFlagEffect(tp,id)==0 -- Can inflict 300
    local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) -- Can Special Summon
    if chk==0 then return b1 or b2 end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

----------------------------------------------------------
-- Operation
----------------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.GetFlagEffect(tp,id)==0
    local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    if not (b1 or b2) then return end

    local opt=0
    if b1 and b2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        Duel.SelectOption(tp,aux.Stringid(id,1))
        opt=0
    else
        Duel.SelectOption(tp,aux.Stringid(id,2))
        opt=1
    end

    if opt==0 then
        -- Inflict 300 damage
        Duel.Damage(1-tp,300,REASON_EFFECT)
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    else
        -- Special Summon
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
        end
    end
end
