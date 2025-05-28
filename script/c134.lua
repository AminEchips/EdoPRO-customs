--Supreme Summon
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Only 1 can be controlled
	c:SetUniqueOnField(1,0,id)

	--Main Ignition Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Filters
function s.excostfilter(c)
	return (c:IsSetCard(0x20f8) or c:IsCode(13331639)) and (c:IsFaceup() or c:IsFacedown()) and c:IsAbleToGraveAsCost()
end
function s.setfilter(c)
	return (c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)) and c:ListsCode(13331639) and c:IsSSetable()
end
function s.revealcostfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(8)
end
function s.spsumfilter(c,e,tp)
	return (c:IsSetCard(0x20f8) or c:IsCode(13331639)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.ctrlfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x20f8) or c:IsCode(13331639))
end

-- Choose one of 4 effects
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.excostfilter,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.revealcostfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b3=Duel.IsExistingMatchingCard(s.spsumfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b4=Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)

	if chkc then return false end
	if chk==0 then return b1 or b2 or b3 or b4 end

	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)}) - 1
	e:SetLabel(op)

	if op==2 then
		-- Effect 3: Target monster in GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spsumfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	elseif op==3 then
		-- Effect 4: Banish 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- Send from Extra Deck as cost, then set a card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.excostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SSet(tp,sg)
			end
		end

	elseif op==1 then
		-- Reveal Pendulum as cost, discard, then place it in Pendulum Zone
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.revealcostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #g==0 then return end
		local rc=g:GetFirst()
		Duel.ConfirmCards(1-tp,rc)
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 and rc:IsRelateToEffect(e) then
			if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
				Duel.MoveToField(rc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end


	elseif op==2 then
		-- Target and Special Summon ignoring conditions
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end

	elseif op==3 then
		-- Must control Z-ARC or Supreme King Dragon to banish
		if not Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_MZONE,0,1,nil) then return end
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
