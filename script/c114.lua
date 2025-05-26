--Supreme King Gate Magician Arc-Stargazer
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	--Pendulum Scale adjustment
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetCondition(s.scalecon)
	e1:SetValue(4)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2)

	--Special Summon itself when a Level 10+ Pendulum Monster is Pendulum Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.pscon)
	e3:SetOperation(s.psop)
	c:RegisterEffect(e3)

	--Direct attack defense: destroy 2 Pendulum Zones, end Battle Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.bpcon)
	e4:SetTarget(s.bptg)
	e4:SetOperation(s.bpop)
	c:RegisterEffect(e4)

	--Special Summon restriction
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(function(e,se,sp,st) return st==SUMMON_TYPE_PENDULUM or (se and se:GetHandler()==e:GetHandler()) end)
	c:RegisterEffect(e5)

	--Immunity to Spell Effects + ATK/DEF swap (Quick if 3+ Pendulums)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(s.banishcost)
	e6:SetCondition(s.quickcon_ignition)
	e6:SetOperation(s.swapop)
	c:RegisterEffect(e6)

	local e6q=e6:Clone()
	e6q:SetType(EFFECT_TYPE_QUICK_O)
	e6q:SetCode(EVENT_FREE_CHAIN)
	e6q:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e6q:SetCondition(s.quickcon_quick)
	c:RegisterEffect(e6q)

	--Place in Pendulum Zone if destroyed
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e7:SetTarget(s.pztg)
	e7:SetOperation(s.pzop)
	c:RegisterEffect(e7)
end

--Scale condition
function s.scalecon(e)
	return not Duel.IsExistingMatchingCard(function(c)
		return c:IsType(TYPE_PENDULUM) and c:IsLevel(10)
	end,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end

--Pendulum Summon of Level 10+ triggers Special Summon
function s.psfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(10)
		and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsControler(tp)
end
function s.pscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.psfilter,1,nil,tp)
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Direct attack condition
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.bptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,2,nil)
	end
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_PZONE,0,nil)
	if #g>=2 then
		local dg=g:Select(tp,2,2,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.NegateAttack()
	end
end

--Cost: banish self temporarily
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)
	-- Return to field at End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(c)
	e1:SetCountLimit(1)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.ReturnToField(e:GetLabelObject())
	end)
	Duel.RegisterEffect(e1,tp)
end

--Condition for Quick Effect (3+ Pendulum monsters)
function s.quickcon_quick(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_PENDULUM)>=3
end
--Condition for Ignition (less than 3 Pendulum monsters)
function s.quickcon_ignition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_PENDULUM)<3
end

--Effect: Immunity and ATK/DEF swap
function s.swapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	--Spell immunity for Pendulums
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsType(TYPE_PENDULUM) end)
	e1:SetValue(function(e,re) return re:IsActiveType(TYPE_SPELL) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	--Swap ATK/DEF of opponent monsters
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3:SetValue(atk)
		tc:RegisterEffect(e3)
	end
end

--Place in Pendulum Zone when destroyed
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	elseif Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
