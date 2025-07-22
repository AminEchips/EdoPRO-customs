--Fenrir, the Midgard Nordic Wolf
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--Cannot be used as Synchro Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	--Indestructible by card effects while in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsDefensePos() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--Unaffected by its controller's other card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)

	--Start of Battle Phase: switch control, lock position, must attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.ctrlcon)
	e3:SetTarget(s.ctrltg)
	e3:SetOperation(s.ctrlop)
	c:RegisterEffect(e3)

	--If this card attacks: lose ATK equal to opponent’s monster, opponent draws 1
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end

--Unaffected by its controller’s other effects
function s.efilter(e,te)
	return te:GetOwnerPlayer()==e:GetHandlerPlayer()
end

--Start of Battle Phase: if in ATK Position and controlled by you
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsAttackPos() and c:IsControler(tp)
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsControlerCanBeChanged() end
	Duel.SetTargetCard(c)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then return end
	if Duel.GetControl(tc,1-tp)==0 then return end

	--Cannot change battle position
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)

	--Must attack
	local e2=Effect.CreateEffect(tc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end

--Lose ATK and opponent draws 1 during damage calc
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or not bc or not bc:IsRelateToBattle() then return end
	local atk=bc:GetAttack()
	if atk<0 then atk=0 end
	--Lose ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	--Opponent draws 1
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
