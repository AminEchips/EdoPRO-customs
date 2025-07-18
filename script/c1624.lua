--Asgard, Home of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Aesir from GY -> opponents' attack targets change to Defense Position during next turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.chgposcon)
	e1:SetOperation(s.chgposop)
	c:RegisterEffect(e1)

	--Effect 2: When this card leaves the field, special summon Tuners from hand then Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

--List of Aesir monsters
s.aesir_list={93483212,1621,1647,30604579,1619,67098114,1620}
function s.is_aesir(c)
	return c:IsSetCard(0x4b)
end

--Effect 1: Setup effect if Aesir is Special Summoned from GY
function s.chgposcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return s.is_aesir(c) and c:IsPreviousLocation(LOCATION_GRAVE) and c:GetSummonPlayer()==tp
	end,1,nil)
end
function s.chgposop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local at=Duel.GetAttackTarget()
		local tc=Duel.GetAttacker()
		if tc:IsControler(tp) and tc:IsSetCard(0x4b) and at and at:IsAttackPos() then
			Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
		end
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end

--Effect 2: On leave field, summon Tuners from hand and optionally Synchro
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	while true do
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_TUNER)
		if #g==0 then break end
		if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,99,nil)
		if #sg==0 then break end
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local syncg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
		if #syncg==0 then break end
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=syncg:Select(tp,1,1,nil):GetFirst()
			if sc then
				Duel.SynchroSummon(tp,sc,nil)
			end
		else
			break
		end
	end
end
