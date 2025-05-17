--Branded Unshattering
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
    -- Target protection
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    -- Set this card during the End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

s.listed_names={68468459} -- Fallen of Albaz

function s.filter(c)
    return c:IsFaceup() and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_TUNER))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Cannot be destroyed
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        tc:RegisterEffect(e2)
        -- Cannot have effects negated
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_DISABLE)
        tc:RegisterEffect(e3)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_CANNOT_NEGATE_EFFECT)
        tc:RegisterEffect(e4)
        -- Track that this card was used to activate Albaz's effect this turn
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(id)
        e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e5:SetTargetRange(1,0)
        e5:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e5,tp)
    end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    -- Checks if this card was sent to GY this turn due to activating Albaz effect
    return Duel.GetFlagEffect(tp,id)>0 and e:GetHandler():IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SSet(tp,c)
        Duel.ConfirmCards(1-tp,c)
    end
end
