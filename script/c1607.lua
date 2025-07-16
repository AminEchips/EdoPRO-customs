--Dvallin of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand + optionally banish from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Return banished Level 5+ monster and optionally destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.retcost)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.matcon)
	c:RegisterEffect(e3)
end

-- Control no monsters or only "Nordic" monsters
function s.cfilter(c)
	return not c:IsSetCard(0x42)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Effect 1: Special Summon + optional banish from Deck
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=g:Select(tp,1,1,nil)
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- Effect 2 & 3: Synchro condition
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r & REASON_SYNCHRO ~= 0 and rc:IsType(TYPE_SYNCHRO)
end

-- Cost: select banished Level 5+ monster
function s.retfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
end

-- Targeting confirmation
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc and tc:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

-- Return to hand + optional destruction
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
	end

	-- If used as Synchro material: allow destroy
	local rc=e:GetHandler():GetReasonCard()
	if rc and rc:IsType(TYPE_SYNCHRO) and e:GetHandler():IsReason(REASON_MATERIAL) then
		local dg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsLevel(lv) end,tp,0,LOCATION_MZONE,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
