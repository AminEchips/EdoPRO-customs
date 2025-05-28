--Magical Star Illusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Give permanent ATK boost
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY effect: Add up to 2 "Magician" Pendulum Monsters, then send 1 card to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.gycon)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
s.listed_series={0x98} -- Magician archetype

-- Field effect target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end

-- Field effect operation: Boost ATK permanently by 500 × Pendulum Zone cards
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_PZONE,0,nil)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- GY condition: Not usable the turn it was sent there
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnCount()~=c:GetTurnID()
end

-- GY cost: Banish this card
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end

-- GY filter: Magician Pendulum Monsters
function s.thfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end

-- GY Target
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- GY Operation
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if #dg>0 then
			Duel.SendtoGrave(dg,REASON_EFFECT)
		end
	end
end
