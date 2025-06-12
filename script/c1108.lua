--Salamangreat Vulcan Grizzly
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnableCheckReincarnation(c)

	-- Synchro Summon procedure: 1 FIRE Tuner + 1+ non-Tuner FIRE monsters
	Synchro.AddProcedure(c,
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE), 1, 1,
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE), 1, 99)
	c:EnableReviveLimit()

	-- While Linked: Becomes Level 5
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetCondition(s.linkcon)
	e1:SetValue(5)
	c:RegisterEffect(e1)

	-- While Linked: Can attack in Defense Position using DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetCondition(s.linkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- On Battle Destroy: gain 2 more attacks and go to Attack Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(aux.bdocon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)

	-- Reincarnation Synchro effect: change to DEF + gain 2800 DEF
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.reincon)
	e4:SetTarget(s.reintg)
	e4:SetOperation(s.reinop)
	c:RegisterEffect(e4)
end
s.listed_series={0x119}

-- While Linked condition
function s.linkcon(e)
	local c=e:GetHandler()
	return c:IsLinked()
end

-- Battle destroy effect: go to ATK + gain 2 attacks
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Change to Attack Position
		if c:IsDefensePos() then
			Duel.ChangePosition(c,POS_FACEUP_ATTACK)
		end
		-- Gain 2 more attacks this Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- Reincarnation Synchro Summon condition
function s.reincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsReincarnationSummoned() and c:IsAttackPos()
end

-- Reincarnation: change to DEF + gain 2800 DEF
function s.reintg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.reinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(2800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
