function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end

    -- Schedule the second attack effect during next Battle Phase
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetDescription(aux.Stringid(id,2))
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
