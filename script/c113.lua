--Supreme King Gate Magician Arc-Timegazer
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

	--SS itself if Level 10+ Pendulum is Pendulum Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.pscon)
	e3:SetOperation(s.psop)
	c:RegisterEffect(e3)

	--Summon restriction
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(function(e,se,sp,st) return st==SUMMON_TYPE_PENDULUM or se and se:GetHandler()==e:GetHandler() end)
	c:RegisterEffect(e4)

	--Negate Spells/Traps on SS (non-chainable)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) end)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)

	--Draw 2 if added to ED face-up
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_MOVE)
	e6:SetCountLimit(1,id+200)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
			and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
	end)
	e6:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end)
	e6:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end)
	c:RegisterEffect(e6)

	--Place in Pendulum Zone if destroyed
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e7:SetOperation(s.placeop)
	c:RegisterEffect(e7)
end

--Scale condition: no other Level 10 Pendulum
function s.scalecon(e)
	return not Duel.IsExistingMatchingCard(function(c)
		return c:IsType(TYPE_PENDULUM) and c:IsLevel(10)
	end,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end

--Pendulum Summon trigger
function s.psfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(10) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsControler(tp)
end
function s.pscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.psfilter,1,nil,tp)
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		--Trap immunity for all your monsters
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TRUE)
		e1:SetValue(function(e,re) return re:IsActiveType(TYPE_TRAP) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--Negation on SS (non-chainable)
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_PENDULUM)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local sg=g:Filter(function(c) return c:IsSpellTrap() and c:IsFaceup() end,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tg=sg:Select(tp,1,ct,nil)
	for tc in aux.Next(tg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

--Place in Pendulum Zone
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
