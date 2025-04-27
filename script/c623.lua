function s.dblfilter(c)
    return c:IsFaceup() and c:GetAttack()==0 and (c:IsCode(9012916) or c:ListsCode(9012916))
end

function s.dblcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.dbltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetTargetCard(g)
end

function s.dblop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local base_atk=tc:GetBaseAttack()
        if base_atk>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(base_atk*2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e1)
        end
    end
end
