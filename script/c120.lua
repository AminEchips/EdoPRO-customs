--Odd-Eyes Iris Magician
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()

	-- Fusion Summon requirement: 1 "Odd-Eyes" Dragon + 1 "Magician" Pendulum
	Fusion.AddProcMix(c,true,true,s.mat1filter,s.mat2filter)

	-- Custom Special Summon condition (from Extra Deck via tributing Pendulum Summoned materials)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- Quick Effect: Target 1 monster, negate & destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- On destruction: place into Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e2:SetOperation(s.placeop)
	c:RegisterEffect(e2)
end

s.listed_series={0x99,0x98,0xf2} -- Odd-Eyes, Magician, Pendulum
s.material_setcode={0x99,0x98}

-- Fusion materials
function s.mat1filter(c,fc,sumtype,tp)
	return c:IsSetCard(0x99,fc,sumtype,tp) and c:IsRace(RACE_DRAGON)
end
function s.mat2filter(c,fc,sumtype,tp)
	return c:IsSetCard(0x98,fc,sumtype,tp) and c:IsType(TYPE_PENDULUM)
end

-- Special summon restriction: Must be Fusion Summoned or from ED by tributing proper Pendulum Summoned monsters
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if st==SUMMON_TYPE_FUSION then return true end
	if se then
		local tg=se:GetTarget()
		if se:IsHasType(EFFECT_TYPE_ACTIONS) or not tg then return false end
	end
	return false -- default to Fusion Summon only for safety
end

-- Quick Effect: Negate and destroy a face-up monster
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- If destroyed: move to Pendulum Zone
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
