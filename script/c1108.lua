--Salamangreat Vulcan Grizzly
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnableCheckReincarnation(c)

	-- Synchro Summon
	Synchro.AddProcedure(c,
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),
		1,1,
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),1,99)
	c:EnableReviveLimit()

	-- While Linked: becomes Level 5, can attack in DEF using DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetCondition(s.linkcon)
	e1:SetValue(5)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetCondition(s.linkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_DAMAGE_CAL)
	e3:SetCondition(s.linkcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	-- On battle destroy: switch to ATK and gain 2 more attacks
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(aux.bdocon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)

	-- If Reincarnation Synchro Summoned: Quick DEF boost + position change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.reincon)
	e5:SetTarget(s.reintg)
	e5:SetOperation(s.reinop)
	c:RegisterEffect(e5)
end
s.listed_series={0x119}

-- While Linked
function s.linkcon(e)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()
	return zone&c:GetLinkedZone()~=0 or c:IsLinked()
end

-- On battle destroy: gain 2 more attacks
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Change to Attack Position if not already
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

-- Reincarnation Synchro check
function s.reincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsReincarnationSummoned() and c:IsAttackPos()
end

function s.reintg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end

function s.reinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- Gain 2800 DEF until opponent's End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(2800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
