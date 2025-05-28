--Supreme Summon
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Only 1 can be controlled
	c:SetUniqueOnField(1,0,id)

	-- Main effect: choose 1 of 4
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

s.listed_names={13331639}
-- Filters
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:ListsCode(13331639) and c:IsSSetable()
end
function s.excostfilter(c)
	return (c:IsSetCard(0x20f8) or c:IsCode(13331639)) and (c:IsFaceup() or c:IsFacedown()) and c:IsAbleToGraveAsCost()
end
function s.fdfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(8)
end
function s.gyfilter(c,e,tp)
	return (c:IsSetCard(0x20f8) or c:IsCode(13331639)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.ctrlfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x20f8) or c:IsCode(13331639))
end

-- Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.excostfilter,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.fdfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b3=Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b4=Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)

	if chkc then return false end
	if chk==0 then return b1 or b2 or b3 or b4 end

	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)}, -- send & set
		{b2,aux.Stringid(id,2)}, -- reveal & place
		{b3,aux.Stringid(id,3)}, -- revive
		{b4,aux.Stringid(id,4)}) - 1
	e:SetLabel(op)

	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end

-- Operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==0 then
		-- Effect 1: Send from Extra Deck as cost, then set a Spell/Trap
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
		-- Effect 2: Reveal Pendulum, discard, then place in Pendulum Zone
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #g==0 then return end
		local tc=g:GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		e:SetLabelObject(tc)

		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
			local pendulum=e:GetLabelObject()
			if pendulum and Duel.GetLocationCount(tp,LOCATION_PZONE)>0 then
				Duel.MoveToField(pendulum,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end

	elseif op==2 then
		-- Effect 3: Target and Special Summon, ignoring conditions
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end

	elseif op==3 then
		-- Effect 4: If controlling Z-ARC or SKD, banish any target
		if not Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_MZONE,0,1,nil) then return end
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
