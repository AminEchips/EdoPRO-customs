--Arcgazer Magician
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	-- Pendulum Effect: Change scale of other Pendulum Zone card to 13 if Z-ARC is controlled
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)

	-- Loses 500 ATK for each Pendulum Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c)
		return -500 * Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_MZONE,0,nil,TYPE_PENDULUM)
	end)
	c:RegisterEffect(e2)

	-- If Pendulum Summoned with another monster: banish protection
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.banishcon)
	e3:SetOperation(s.banishop)
	c:RegisterEffect(e3)

	-- If Pendulum card is destroyed, banish this card to Set Z-ARC Spell/Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

-- Z-ARC must be controlled
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,13331639)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local zone1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local zone2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local tc=nil
	if zone1 and zone2 then
		local g=Group.FromCards(zone1, zone2)
		g:RemoveCard(e:GetHandler())
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
	elseif zone1 and zone1~=e:GetHandler() then
		tc=zone1
	elseif zone2 and zone2~=e:GetHandler() then
		tc=zone2
	end
	if tc and tc:IsFaceup() and tc:IsType(TYPE_PENDULUM) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(13)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
end

-- Condition: Pendulum Summoned with another monster
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,c)>0
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_PENDULUM) end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end

-- Trigger if a Pendulum card in MZone or PZone is destroyed while this card is face-up in ED
function s.thcfilter(c,tp)
	return c:IsType(TYPE_PENDULUM)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_PZONE))
		and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.setfilter(c)
	return c:IsSpellTrap() and (c:ListsCode(13331639) or c:IsCode(13331639)) and c:IsSSetable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		-- If Quick-Play or Trap, allow activation this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetTargetRange(LOCATION_SZONE,0)
		e1:SetTarget(function(e,c) return c==tc and c:IsType(TYPE_TRAP) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e2:SetTarget(function(e,c) return c==tc and c:IsType(TYPE_QUICKPLAY) end)
		Duel.RegisterEffect(e2,tp)
	end
end
