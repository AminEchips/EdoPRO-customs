--Dvallin of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)
	-- Normal Summon itself and optionally banish 1 "Nordic"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.nscon)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)

	-- Return 1 banished Level 5+ monster and optionally destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(s.thcon2)
	c:RegisterEffect(e3)
end

-- Normal Summon condition
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x42)
end
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Normal Summon + optional banish
function s.nsfilter(c)
	return c:IsSummonable(true,nil)
end
function s.banfilter(c)
	return c:IsSetCard(0x42) and c:IsAbleToRemove()
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,e:GetHandler(),1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Summon(tp,c,true,nil)==0 then return end
	-- Optional banish
	if Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- Trigger conditions
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_SYNCHRO)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return true -- any banishment triggers this
end

-- Target for return
function s.thfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToHand()
		or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToExtra())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_TODECK,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	local success=false
	if tc:IsType(TYPE_PENDULUM) and tc:IsLocation(LOCATION_REMOVED) and tc:IsAbleToExtra() then
		success=Duel.SendtoExtraP(tc,tp,REASON_EFFECT)>0
	else
		success=Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
	end
	if success and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,function(c)
			return c:IsFaceup() and c:IsLevel(tc:GetLevel())
		end,tp,0,LOCATION_MZONE,1,1,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
