--Supreme King Dragon Crystal Wing
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon procedure: 1 DARK Pendulum Tuner + 1+ non-Tuner Synchro Monsters
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,s.tunerfilter,1,1,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),1,99)

	-- Must first be Synchro Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)

	-- Quick Effect: Negate 1 monster and all others with same name
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

	-- Continuous: Negate 1 Spell/Trap/Effect each turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- Reset each turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(function(_,tp) if Duel.GetTurnPlayer()~=tp then Duel.ResetFlagEffect(tp,id) end end)
	c:RegisterEffect(e3)

	-- Battle: if opponent has higher ATK, set to original
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end

-- Tuner must be DARK Pendulum
function s.tunerfilter(c,sc,tp)
	return c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO,tp)
		and c:IsAttribute(ATTRIBUTE_DARK,sc,SUMMON_TYPE_SYNCHRO,tp)
		and c:IsType(TYPE_PENDULUM,sc,SUMMON_TYPE_SYNCHRO,tp)
end

-- Effect 1: Target a monster, negate it and all with same name
function s.negfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetOriginalCode()
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:GetOriginalCode()==code and not c:IsDisabled()
	end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for mc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		mc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		mc:RegisterEffect(e2)
	end
end

-- Effect 2: Negate first opponent Spell/Trap/effect after a chain
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if ep~=tp and Duel.IsChainDisablable(ev) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- Effect 3: ATK adjustment in battle
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:GetAttack()>c:GetAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		bc:RegisterEffect(e1)
	end
end
