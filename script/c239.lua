--Evil HERO Brimstorm
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion materials: 1 "HERO" Fusion + either Sunrise or Nightfall
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter,s.sunrise_or_nightfall)

	-- Must be Special Summoned with "Dark Fusion"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- DEF to 0 + piercing
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(s.defcon)
	e2:SetOperation(s.defop)
	c:RegisterEffect(e2)

	-- Protect HERO from banish
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.protcon)
	e3:SetTarget(s.prottg)
	e3:SetOperation(s.protop)
	c:RegisterEffect(e3)

	-- Negate spell/trap by banishing + revive a Sunrise/Nightfall
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end

s.listed_names={238,94820406,22908820}
s.material_setcode={0x3008,0x6008,0x8}
s.dark_calling=true

-- Materials: 1 HERO Fusion + (Sunrise or Nightfall)
function s.fusfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION)
end
function s.sunrise_or_nightfall(c)
	return c:IsCode(22908820,238)
end

-- DEF becomes 0
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsPosition(POS_DEFENSE)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end

-- HERO monster battled
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	if bc:IsControler(1-tp) then bc=Duel.GetAttackTarget() end
	return bc and bc:IsSetCard(0x8) and bc:IsRelateToBattle()
end
function s.prottg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
	if not c then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

-- Quick Effect: banish self + negate + revive Sunrise/Nightfall
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(c)
	e1:SetOperation(function(_,tp)
		Duel.ReturnToField(c)
	end)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(22908820,238) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
