--Tri-Brigade Air Stand
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Reveal 1 "Tri-Brigade" monster in hand, send same Type non-Link from ED, SS and draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- GY Effect: trigger if Link monster is banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_series={0x14f} -- Tri-Brigade

-- Activation effect
function s.filter_hand(c,tp)
	return c:IsSetCard(0x14f) and c:IsMonster() and Duel.IsExistingMatchingCard(s.filter_extra,tp,LOCATION_EXTRA,0,1,nil,c,tp)
end
function s.filter_extra(c,hc,tp)
	return c:IsRace(hc:GetRace()) and not c:IsType(TYPE_LINK) and c:IsAbleToGrave() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter_hand,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local hg=Duel.SelectMatchingCard(tp,s.filter_hand,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #hg==0 then return end
	local hc=hg:GetFirst()
	Duel.ConfirmCards(1-tp,hc)
	Duel.ShuffleHand(tp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter_extra,tp,LOCATION_EXTRA,0,1,1,nil,hc,tp)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsRelateToEffect(e)
		and Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- GY Trigger: When your Link monster is banished
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsType(TYPE_LINK)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_REMOVED,0,1,nil) and e:GetHandler():IsAbleToRemoveAsCost() end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end

	if not tc:IsType(TYPE_LINK) or not tc:IsFaceup() then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- Choose: Return+Add or Special Summon
	local opt=0
	if tc:IsAbleToExtra() and c:IsAbleToHand() then opt=0
	elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then opt=1
	else return end

	if opt==0 and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(c,tp,REASON_EFFECT)
	elseif opt==1 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
