--Asgard, Home of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Trigger when Aesir is Special Summoned from GY → apply continuous battle effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(0)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.trigcon)
	e1:SetOperation(s.trigop)
	c:RegisterEffect(e1)

	--Effect 2: On leave field, summon Tuners from hand and allow repeated Synchro Summons
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetOperation(s.leaveop)
	c:RegisterEffect(e2)
end

--=== Effect 1: Trigger on Aesir revived ===--
function s.trigfilter(c,tp)
	return c:IsSetCard(0x4b) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetSummonPlayer()==tp
end
function s.trigcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil,tp)
end
function s.trigop(e,tp,eg,ep,ev,re,r,rp)
	-- Register a temporary continuous effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local a=Duel.GetAttacker()
		return a and a:IsControler(tp) and a:IsSetCard(0x4b)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local at=Duel.GetAttackTarget()
		if at and at:IsRelateToBattle() and at:IsAttackPos() then
			Duel.Hint(HINT_CARD,0,id)
			Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
		end
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end

--=== Effect 2: Summon Tuners and loop Synchro ===--
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local g=Duel.GetMatchingGroup(function(c)
		return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,tp,LOCATION_HAND,0,nil)
	if #g==0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)

	-- Allow repeat Synchro
	while true do
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local syncs=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
		if #syncs==0 then break end
		if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=syncs:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
	end
end
