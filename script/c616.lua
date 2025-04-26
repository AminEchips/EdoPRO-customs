--Blackwing - Yamiro the Thunderstorm Striker
local s,id=GetID()
s.listed_series={0x33} -- Blackwing
s.listed_names={9012916} -- Black-Winged Dragon
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x33),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    
    -- On Synchro Summon: Return, negate and gain attacks
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

----------------------------------------------------------
-- Conditions
----------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

----------------------------------------------------------
-- Filters
----------------------------------------------------------
function s.retfilter(c)
    return (c:IsCode(9012916) or (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_WINGEDBEAST))) 
        and c:IsFaceup() and c:IsAbleToExtra()
end
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end

----------------------------------------------------------
-- Target
----------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.retfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,63,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,#g,0,0)
end

----------------------------------------------------------
-- Operation
----------------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg==0 then return end
    local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
    if ct>0 then
        -- Negate opponent face-up cards
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_MZONE+LOCATION_SZONE,0,ct,ct,nil)
        for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
        end
        local ng=#g
        if ng>0 then
            -- Gain additional attacks on monsters this turn
            local c=e:GetHandler()
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
            e3:SetValue(ng)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e3)
        end
    end
end
