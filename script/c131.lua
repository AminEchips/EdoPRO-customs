--Magical Star Illusion
local s,id=GetID()
function s.initial_effect(c)
	--Always treated as "Pendulumgraph"
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetCode(EFFECT_ADD_SETCODE)
	e0a:SetRange(LOCATION_ALL)
	e0a:SetValue(0x254)
	c:RegisterEffect(e0a)

	--Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--ATK boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsFaceup() end)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	--GY effect: If Spellcaster left field due to opponent, get another from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

-- ATK value based on cards in Pendulum Zones
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
	return g:GetCount()*500
end

-- Condition: Spellcaster left field this turn due to opponent
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,0,nil,e)
	return g:GetCount()>0
end
function s.cfilter(c,e)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(e:GetHandlerPlayer())
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsRace(RACE_SPELLCASTER)
end

-- GY effect target
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end

function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

-- GY effect operation
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	local op=0
	if tc:IsAbleToHand() and tc:IsAbleToGrave() then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- add or send
	elseif tc:IsAbleToHand() then
		op=0
	elseif tc:IsAbleToGrave() then
		op=1
	end
	if op==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
