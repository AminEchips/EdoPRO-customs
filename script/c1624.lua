--Asgard, Home of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Apply continuous effect when Aesir is revived from GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.revivedcon)
	e1:SetOperation(s.revivedop)
	c:RegisterEffect(e1)

	--Effect 2: On leaving field, summon Tuners + allow repeated Synchros
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetOperation(s.leaveop)
	c:RegisterEffect(e2)
end

--===== EFFECT 1 HELPERS: Aesir revived from GY triggers delayed redirect effect =====--
function s.revivedcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsSetCard(0x4b) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetSummonPlayer()==tp
	end,1,nil)
end
function s.revivedop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.changeposcon)
	e1:SetOperation(s.changeposop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end
function s.changeposcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsSetCard(0x4b)
end
function s.changeposop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	if at and at:IsAttackPos() and at:IsRelateToBattle() then
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
	end
end

--===== EFFECT 2: If this card leaves field, summon tuners & Synchro repeatedly =====--
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- Special Summon all Tuners from hand
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,tp,LOCATION_HAND,0,nil)
	if #g==0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)

	-- Allow repeated Synchro Summons
	while true do
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
		if #sg==0 then break end
		if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
	end
end
