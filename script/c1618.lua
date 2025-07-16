--Hela, Grim of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),2,99)
	c:EnableReviveLimit()

	--ATK to 0 or send to GY (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	--Special Summon from GY by banishing 1 other Aesir
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x42,0x4b}

--e1: ATK to 0 or send to GY instead
function s.atkfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	local usingSpellcaster=c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
	if usingSpellcaster and tc:IsAbleToGrave() then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0 = reduce, 1 = send
		if opt==1 then
			if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then return end
		end
	end

	-- apply ATK to 0 after resolution
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e1)
	end
end

--e2: Special Summon from GY
function s.spcfilter(c)
	return c:IsSetCard(0x4b) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
