--Branded Evolution
--Scripted by Meuh, revised
local s,id=GetID()

function s.initial_effect(c)
	-- Activate: Tribute 2 LIGHT/DARK monsters (1 must be "Despia") to summon "Masquerade the Blazing Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- GY Trigger: If a Fusion Monster you control leaves the field, banish this, send 1 "Despia" from Deck/Extra to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_names={06855503} -- Masquerade the Blazing Dragon
s.listed_series={0x166} -- Despia

-- First effect: Tribute 2 (one must be Despia), Special Summon Masquerade
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsReleasable() and c:IsFaceup()
	end,tp,LOCATION_MZONE,0,nil)
	if #g<2 or not g:IsExists(Card.IsSetCard,1,nil,0x166) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:Select(tp,2,2,nil)
	if #rg<2 or not rg:IsExists(Card.IsSetCard,1,nil,0x166) then return end
	if Duel.Release(rg,REASON_EFFECT)==2 and Duel.GetLocationCountFromEx(tp)>0 then
		local tc=Duel.GetFirstMatchingCard(function(c,e,tp)
			return c:IsCode(06855503) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		end,tp,LOCATION_EXTRA,0,nil,e,tp)
		if tc then
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

-- GY trigger condition: Fusion Monster you controlled left the field face-up
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

-- GY cost: banish this card
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- GY target
function s.gyfilter(c)
	return c:IsSetCard(0x166) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

-- GY operation: send 1 Despia from Deck/Extra Deck to GY
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
