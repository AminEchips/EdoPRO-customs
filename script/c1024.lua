--Tri-Brigade Bardawulf the Guiding Glasser
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST),2,2)

	--Quick Effect: Banish and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

-- Cost: Banish 1 Beast, Beast-Warrior, Winged Beast, or "Fallen of Albaz" from hand or field
function s.cfilter(c)
	return (c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST) or c:IsCode(68468459)) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalType())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target for Special Summon from banished zone
function s.spfilter(c,e,tp,typ)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsType(typ)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local typ=e:GetLabel()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,typ)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

-- Operation: Special Summon 1 banished monster with different Type than the banished cost
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp,typ)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
