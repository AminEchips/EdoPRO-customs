--Evil HERO Skullwing Soldier
local s,id=GetID()
function s.initial_effect(c)
	-- Set 1 Spell/Trap that mentions "Dark Fusion"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Banish recovery or Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.revtg)
	e3:SetOperation(s.revop)
	c:RegisterEffect(e3)
end
s.listed_series={0x6008}
s.listed_names={id,94820406} -- "Dark Fusion"

-- Tribute cost
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.FilterBoolFunction(Card.IsSetCard,0x8),1,nil) end
	local g=Duel.SelectReleaseGroup(tp,aux.FilterBoolFunction(Card.IsSetCard,0x8),1,1,nil)
	Duel.Release(g,REASON_COST)
end
-- Settable filter
function s.setfilter(c)
	return c:IsSpellTrap() and c:ListsCode(94820406) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

-- Recover or special summon banished HERO
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.revfilter(c)
	return c:IsSetCard(0x8) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(nil,0,tp,false,false))
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	if tc:IsCanBeSpecialSummoned(nil,0,tp,false,false) and tc:IsHasEffect(94820406)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
