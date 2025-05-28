--Supreme King Dragon Crystal Wing
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,s.tunerfilter,1,1,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),1,99)

	-- Must first be Synchro Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)

	-- Quick Effect: negate 1 monster and same-name cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- Battle ATK fix
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

-- DARK Pendulum Tuner
function s.tunerfilter(c,sc,tp)
	return c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO,tp)
		and c:IsAttribute(ATTRIBUTE_DARK,sc,SUMMON_TYPE_SYNCHRO,tp)
		and c:IsType(TYPE_PENDULUM,sc,SUMMON_TYPE_SYNCHRO,tp)
end

-- Targeting a face-up monster
function s.negfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local code=tc:GetOriginalCode()

	-- Negate that monster
	s.negateMonster(tc)

	-- Negate all other monsters with same name
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:GetOriginalCode()==code and not c:IsDisabled() and c~=tc
	end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for mc in g:Iter() do
		s.negateMonster(mc)
	end

	-- Enable spell/trap negation for this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetLabel(0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
end

function s.negateMonster(tc)
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
end

-- Effect 2.5: Conditional Spell/Trap negation
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then return end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and (loc&LOCATION_ONFIELD)>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
		e:SetLabel(1)
	end
end

-- Effect 3: Battle damage ATK condition
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:GetAttack()>c:GetAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if not bc or not bc:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(bc:GetBaseAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	bc:RegisterEffect(e1)
end
