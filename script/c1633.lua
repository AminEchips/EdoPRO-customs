--Valhalla of the Aesir
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--This card's activation and effects cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_INACTIVATE)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e1)
	local e2=e0:Clone()
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(e2)

	--Effect 1: If you Synchro Summon an "Aesir" monster, add 1 "Aesir" card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	--Effect 2: If a monster(s) is banished from either GY, you can return 1 to hand (3x/turn)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(3,{id,1})
	e4:SetCondition(s.retcon)
	e4:SetTarget(s.rettg)
	e4:SetOperation(s.retop)
	c:RegisterEffect(e4)
end

--Effect 1: Check if an "Aesir" monster was Synchro Summoned
function s.thfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSetCard(0x4b) and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsSetCard(0x4b) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Effect 2: If a monster is banished from either GY
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.retfilter(chkc,e) end
	if chk==0 then return eg:IsExists(s.retfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=eg:Filter(s.retfilter,nil,e):Select(tp,1,1,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.retfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsRelateToEffect(e)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsAbleToHand() and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
