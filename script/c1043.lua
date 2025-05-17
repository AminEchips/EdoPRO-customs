--Branded in Black
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 2 Level 8+ Despia/Fusion monsters from GY into Deck, then draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)

	--GY Fusion Summon using banish, allow Deck material if opp activated a card/effect
	local params = {
		handler = c,
		fusfilter = aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK),
		matfilter = Card.IsAbleToRemove,
		extrafil = s.extrafil,
		extraop = Fusion.BanishMaterial,
		extratg = s.extratg
	}
	local e2=Fusion.CreateSummonEff(params)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	end)
	c:RegisterEffect(e2)
end
s.listed_series={0x166} -- Despia

-- First effect: Shuffle & draw
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x166) or c:IsType(TYPE_FUSION)) and c:IsLevelAbove(8) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg<2 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local g=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if #g>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- GY Fusion: Deck use allowed if opp activated something
function s.check(g1,g2)
	return function(tp,sg,fc)
		local c1=#(sg&g1)
		local c2=#(sg&g2)
		return c1<=1 and c2<=1,c1>1 or c2>1
	end
end
function s.extrafil(e,tp,mg)
	if Duel.GetCurrentChain()<=0 then return nil end
	local loc=LOCATION_DECK
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		loc=loc|LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,loc,0,mg)
	return g,s.check(g:Split(Card.IsLocation,nil,LOCATION_GRAVE))
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE|LOCATION_DECK)
end
