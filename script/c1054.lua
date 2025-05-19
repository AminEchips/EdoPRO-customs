--Swordsoul Deceiver Gongbu
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
	-- Reveal and summon token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end

s.listed_series={0x16d}

-- Condition: no monsters or only Wyrms
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(Card.IsRace,nil,RACE_WYRM)==#g
end

-- Cost: reveal this + 1 Wyrm or Swordsoul card in hand
function s.tkcostfilter(c)
	return (c:IsSetCard(0x16d) or c:IsRace(RACE_WYRM)) and not c:IsPublic()
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.tkcostfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end

-- Target for token
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x16d,TYPES_TOKEN|TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

-- Token creation + restriction + optional search
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local token=Duel.CreateToken(tp,id+1)
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Restrict Extra Deck Special Summon except Synchro
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Lizard Check
	local e2=aux.createContinuousLizardCheck(e:GetHandler(),LOCATION_MZONE,function(_,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	-- Optional search if you control Synchro
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and e:GetHandler():IsDiscardable() then
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
	end
end

function s.thfilter(c)
	return c:IsSetCard(0x16d) and c:IsSpellTrap() and c:IsAbleToHand()
end
