--Noble Knight Geraint
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Discard to search Merlin, Lady, or Avalon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Effect 2: On Special Summon, empower LIGHT/DARK NK Synchro/Xyz
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

s.listed_series={0x107a} -- Noble Knight
s.listed_names={03580032,10736540,82140600,24027078} -- Merlin, Lady, Avalon cards

-- Effect 1: Discard to search
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
    return c:IsCode(03580032,10736540,82140600,24027078) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Effect 2: Condition to trigger on Special Summon
function s.synxyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x107a)
        and (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ))
        and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.synxyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.synxyzfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.synxyzfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.synxyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end

    -- Schedule the extra attack for next Battle Phase
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e0:SetCountLimit(1)
    e0:SetLabelObject(tc)
    e0:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
    e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local sc=e:GetLabelObject()
        if sc and sc:IsFaceup() and sc:IsControler(tp) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EXTRA_ATTACK)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            sc:RegisterEffect(e1)
        end
        e:Reset()
    end)
    Duel.RegisterEffect(e0,tp)

    -- Cannot be destroyed by battle
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)

    -- Return to Extra Deck when it leaves the field
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
    e3:SetValue(LOCATION_EXTRA)
    tc:RegisterEffect(e3,true)
end
