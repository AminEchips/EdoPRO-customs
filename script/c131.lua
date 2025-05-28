--Magical Star Illusion
local s,id=GetID()
function s.initial_effect(c)
	-- Always treated as "Pendulumgraph"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(0x254) -- Arbitrary code for "Pendulumgraph"
	c:RegisterEffect(e0)

	-- ATK boost for all face-up monsters you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	-- GY effect: search 2 "Magician" Pendulums then send 1 card to GY
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

-- ATK gain = total Levels of Pendulum Zone monsters x100
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_PZONE,0,nil,TYPE_MONSTER)
	local lv=g:GetSum(Card.GetLevel)
	return lv*100
end

-- GY effect: only usable if not sent this turn
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

-- Search "Magician" Pendulum monsters
function s.thfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- Add up to 2 "Magician" Pendulum Monsters
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	-- Send 1 card from hand or field to GY
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
