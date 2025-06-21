--Salamangreat Crest
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Rank-Up Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--GY Effect: Set from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

--=== Effect 1 ===
function s.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk)
end
function s.filter2(c,e,tp,mc,rk)
	return c:IsSetCard(0x119) and c:IsType(TYPE_XYZ)
		and (c:GetRank()==rk or c:GetRank()==rk*2)
		and mc:IsCanBeXyzMaterial(c)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local rk=tc:GetRank()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,rk)
	local sc=g:GetFirst()
	if sc then
		local mat=tc:GetOverlayGroup()
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,mat)
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

--=== Effect 2 ===
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():IsPreviousLocation(LOCATION_DECK) or e:GetHandler():IsPreviousLocation(LOCATION_HAND))
end
function s.setfilter(c)
	return c:IsSetCard(0x119) and (c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function s.shuffilter(c,code)
	return c:IsAbleToDeck() and c:IsCode(code)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetCode()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shuffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,tc,code)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) and e:GetHandler():IsRelateToEffect(e) then
			Duel.SSet(tp,e:GetHandler())
			Duel.ConfirmCards(1-tp,Group.FromCards(e:GetHandler()))
		end
	end
end
