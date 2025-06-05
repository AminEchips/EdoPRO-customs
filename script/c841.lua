--Memory of Requiem
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and choose Rank 5 Xyz Dragon on resolution (not targeting)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filter for eligible monsters
function s.filter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsRank(5)
end

-- Apply effects on resolution (choose 1 Rank 5 Xyz Dragon)
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end

    -- Effect 1: Start of Damage Step immunity
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetOperation(s.immop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1,true)

    -- Effect 2: End of Damage Step double attack effect
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.chaincon)
    e2:SetOperation(s.chainop)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2,true)
end

-- Effect 1: Start of Damage Step condition
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp)
end

function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToBattle() then return end

    -- Unaffected by opponent's effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
    c:RegisterEffect(e1)

    -- Opponent takes no battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
    c:RegisterEffect(e2)
end

-- Effect 2: End of Damage Step second attack condition
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and c:IsRelateToBattle() and Duel.GetBattleDamage(1-tp)==0
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToBattle() or not c:IsFaceup() then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_MZONE,0,1,c) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,LOCATION_MZONE,0,1,1,c)
    local tc=g:GetFirst()
    if not tc or Duel.Release(tc,REASON_EFFECT)==0 then return end

    local atk=tc:GetBaseAttack()
    if atk<0 then atk=0 end

    -- Allow second direct attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    -- Must attack directly
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetValue(function(e,c) return c:IsControler(1-e:GetHandlerPlayer()) end)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)

    -- Burn damage = tributed monster's original ATK if opponent still has monsters
    if Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) then
        Duel.BreakEffect()
        Duel.Damage(1-tp,atk,REASON_EFFECT)
    end
end
