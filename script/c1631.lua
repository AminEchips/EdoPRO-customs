--Svartalfheim, Home of the Dark Elves
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Choose 1 of 2 effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xa042) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3042)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=0
		Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=1
		Duel.SelectOption(tp,aux.Stringid(id,2))
	end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- Special Summon 1 "Nordic Alfar" from hand or banished
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 1 "Nordic Ascendant" becomes "Nordic Alfar" and DARK
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local tc=Duel.SelectMatchingCard(tp,s.chfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- Add "Nordic Alfar" archetype
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
			e1:SetValue(0xa042)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)

			-- Change Attribute to DARK
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(ATTRIBUTE_DARK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
