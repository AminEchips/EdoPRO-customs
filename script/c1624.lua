--Asgard, Home of the Aesir
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--If Aesir is revived: next turn, shift battle targets to DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	--If this card leaves the field: summon Tuners then Synchro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={0x4b} -- Aesir

-- Effect 1: Check if Aesir is revived from GY
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsSetCard(0x4b) and c:IsPreviousLocation(LOCATION_GRAVE) end,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(s.changeop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2) -- lasts until end of your next turn
	Duel.RegisterEffect(e1,tp)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if tc:IsControler(tp) and tc:IsSetCard(0x4b) and at and at:IsAttackPos() then
		Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
	end
end

-- Effect 2: On leave field -> Special Summon Tuners then Synchro loop
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.synfilter(c,mg)
	return c:IsSetCard(0x4b) and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,0,1,nil,c) and c:IsSynchroSummonable(nil,mg)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g==0 then return end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,ct,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- Loop Synchro Summon as long as possible
	while true do
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local exg=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,mg)
		if #exg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=exg:Select(tp,1,1,nil):GetFirst()
		if not sc then break end
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end
