--Asgard, Home of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--1. If an "Aesir" monster is Special Summoned from the GY, change attack targets to Defense Position for your next turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(function(c) return c:IsSetCard(0x4b) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetSummonPlayer()==tp end,1,nil)
	end)
	e1:SetOperation(s.attackchangeop)
	c:RegisterEffect(e1)

	--2. If this card leaves the field: Special Summon Tuners + perform repeated Aesir Synchros
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetOperation(s.tunerandsynchro)
	c:RegisterEffect(e2)
end

function s.attackchangeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetAttacker()
		local at=Duel.GetAttackTarget()
		if tc:IsControler(tp) and tc:IsSetCard(0x4b) and at and at:IsAttackPos() then
			Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
		end
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end

function s.tunerandsynchro(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_TUNER)
	if #g==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	--Special Summon all Tuners in hand
	local tg=g:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	if #tg==0 then return end
	Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)

	--Now repeatedly ask to Synchro Summon using Aesir materials
	while true do
		local mg=Duel.GetMatchingGroup(Card.IsOnField,tp,LOCATION_MZONE,0,nil)
		local sg=Duel.GetMatchingGroup(s.aesirSynchroFilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
		if #sg==0 then break end

		if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then break end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if not sc then break end
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end

function s.aesirSynchroFilter(c,e,tp,mg)
	return c:IsSetCard(0x4b) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mg)
end
