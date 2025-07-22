--Fenrir, the Midgard Nordic Wolf
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--Cannot be used as Synchro Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	--Indestructible by card effects while in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(s.defcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--Unaffected by controller's other effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)

	--Start of Battle Phase: switch control, cannot change battle position, must attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.bpcon)
	e3:SetOperation(s.bpop)
	c:RegisterEffect(e3)

	--Must attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e4)

	--Lose ATK and opponent draws 1 during damage calculation
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
s.listed_series={0x42}

--Cannot be destroyed by effects in DEF
function s.defcon(e)
	return e:GetHandler():IsDefensePos()
end

--Immune to effects of its controller
function s.immval(e,te)
	return te:GetOwnerPlayer()==e:GetHandlerPlayer()
end

--At Battle Phase start: switch control if in Attack Position
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==tp and c:IsAttackPos() and c:IsControler(tp)
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsControler(tp) or not c:IsAttackPos() then return end
	if not Duel.IsPlayerCanControlMonster(1-tp) then return end
	if Duel.GetControl(c,1-tp)==0 then return end

	--Cannot change battle position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)

	--Must attack if able
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end

--Damage calc: loses ATK equal to target's ATK, opponent draws 1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsControler(1-tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or not bc:IsRelateToBattle() or bc:IsFacedown() then return end
	local val=bc:GetAttack()
	if val<0 then val=0 end
	-- Reduce ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e1)
	-- Opponent draws 1
	Duel.BreakEffect()
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
