--Asgard, Home of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Apply battle redirect when Aesir revived from GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	--Effect 2: On leaving field, summon Tuners + Synchro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetOperation(s.leaveop)
	c:RegisterEffect(e2)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsSetCard(0x4b) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetSummonPlayer()==tp end,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local at=Duel.GetAttackTarget()
		local a=Duel.GetAttacker()
		if at and a:IsControler(tp) and a:IsSetCard(0x4b) and at:IsAttackPos() then
			Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
		end
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end

function s.tunerfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end

function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_HAND,0,nil)
	if #g==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	for tc in sg:Iter() do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()

	--Looping Synchro Summon
	while true do
		local exg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
		local syncs=Duel.GetMatchingGroup(aux.SynConditionFilter(nil,SUMMON_TYPE_SYNCHRO,tp,false,false),tp,LOCATION_EXTRA,0,nil,nil,exg)
		if #syncs==0 then break end
		if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=syncs:Select(tp,1,1,nil):GetFirst()
		local mg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,99,nil)
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end
