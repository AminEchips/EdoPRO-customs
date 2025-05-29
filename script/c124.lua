--Odd-Eyes Lightstream Dragon
local s,id=GetID()

-- Requires 2 Effect Monsters, including an "Odd-Eyes" Pendulum Monster
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(function(c) return c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM,lc,sumtype,tp) end,1,nil)
end

function s.initial_effect(c)
	-- Link Summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)

	-- On Link Summon: Special Summon from PZone + place Pendulum Monsters from Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.lkcon)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	-- If a monster is Special Summoned from Extra Deck to a zone it points to: search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Check if Link Summoned
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- PZone Special Summon targets: Performapal, Magician, or Odd-Eyes
function s.pzfilter(c,e,tp)
	return (c:IsSetCard(0x9f) or c:IsSetCard(0x98) or c:IsSetCard(0x99))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Face-up Pendulum Monsters from Extra Deck
function s.extraPendFilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zoneCount=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return zoneCount>0 and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local zoneCount=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if zoneCount<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_PZONE,0,1,math.min(2,zoneCount),nil,e,tp)

	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local count=#g
		if Duel.GetMatchingGroupCount(s.extraPendFilter,tp,LOCATION_EXTRA,0,nil)>=count
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local pg=Duel.SelectMatchingCard(tp,s.extraPendFilter,tp,LOCATION_EXTRA,0,count,count,nil)
			for tc in aux.Next(pg) do
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end

-- If monster is Summoned from ED to a zone this points to
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(function(sc)
		return sc:IsSummonLocation(LOCATION_EXTRA) and c:GetLinkedGroup():IsContains(sc)
	end,1,nil)
end

function s.thfilter(c)
	return c:IsSetCard(0xf2) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
