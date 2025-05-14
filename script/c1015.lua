--Aluber, the Magnum Opus of Despia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,45005708,s.matfilter) -- "The Bystial Aluber"

	-- Effect 1: All monsters on the field become Despia and LIGHT/DARK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.fuscon)
	e1:SetValue(0x166)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
	c:RegisterEffect(e2)

	-- Effect 2: If Albaz in GY, target and banish 1 Despia monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)

	-- Effect 3: If Despia is banished, recover and shuffle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={0x166} -- Despia
s.listed_names={68468459,45005708} -- Fallen of Albaz, The Bystial Aluber

function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x189) -- Bystial Xyz
end

function s.fuscon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,68468459),tp,LOCATION_GRAVE,0,1,nil)
end
function s.rmfilter(c)
	return c:IsSetCard(0x166) and c:IsMonster() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return false end
	return eg:IsExists(function(c)
		return c:IsSetCard(0x166) and c:IsMonster()
			and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	end,1,nil)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:Select(tp,2,2,nil)
	Duel.ConfirmCards(1-tp,sg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=sg:Select(tp,1,1,nil)
	local th=tg:GetFirst()
	sg:RemoveCard(th)
	if th then
		Duel.SendtoHand(th,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
	if #sg>0 then
		Duel.SendtoDeck(sg:GetFirst(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
