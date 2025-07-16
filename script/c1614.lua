--Brunhilde of the Nordic Valkyries
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x3042),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	-- Draw 1, and optionally add Gotterdammerung if Spell activated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	-- Destroy S/T, possibly activate or set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0x42,0x4b}
s.listed_names={91148083}

-- e1
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.gotfilter(c)
	return c:IsCode(91148083) and c:IsAbleToHand()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local spell_activated_this_turn=Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsType,TYPE_SPELL),tp,LOCATION_ONFIELD,0,1,nil)
	if spell_activated_this_turn and Duel.IsExistingMatchingCard(s.gotfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.gotfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			local code=g:GetFirst():GetCode()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(function(_,re) return re:GetHandler():IsCode(code) end)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

-- e2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x4b)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.lokifilter(c)
	return c:IsFaceup() and c:IsCode(67098114,1620)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if tc:IsType(TYPE_SPELL) and (tc:IsType(TYPE_QUICKPLAY) or tc:IsType(TYPE_NORMAL))
		and tc:CheckActivateEffect(false,true,true) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local te=tc:CheckActivateEffect(false,true,true)
		if te then
			local op=te:GetOperation()
			if op then op(te,tp,eg,ep,ev,re,r,rp) end
		end
	end
	if tc:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(s.lokifilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_TRAP)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end
	end
end
