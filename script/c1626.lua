--Alfheim, Home of the Light Elves
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Ignition effect: Choose one of two effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x3042,0x42} -- Nordic Ascendant, Nordic

function s.filter_discard(c)
	return c:IsSetCard(0x3042) and c:IsDiscardable(REASON_EFFECT)
end
function s.filter_add(c)
	return c:IsSetCard(0x42) and not c:IsSetCard(0x3042) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(s.filter_discard,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.filter_add,tp,LOCATION_GRAVE,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		return b1 or b2
	end
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,1-tp,LOCATION_MZONE)
	end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dc=Duel.SelectMatchingCard(tp,s.filter_discard,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if dc and Duel.SendtoGrave(dc,REASON_EFFECT+REASON_DISCARD)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.filter_add,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- Prevent it from attacking Nordic Ascendant monsters next turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetLabelObject(tc)
			e1:SetValue(function(e,c) return c:IsSetCard(0x3042) end)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
