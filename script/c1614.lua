--Brunhilde of the Nordic Valkyries
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--Draw + optionally add "Gotterdammerung"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	--Destroy + apply effect or Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--Global check for Spell activation this turn
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
s.listed_names={91148083} -- Gotterdammerung
s.listed_series={0x42} -- Nordic

--Must use a "Nordic Ascendant" Tuner
function s.tfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_TUNER,scard,sumtype,tp) and c:IsSetCard(0x3042,scard,sumtype,tp)
end

--Check if Synchro Summoned
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--Check if a Spell was activated this turn
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and rp==tp then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

--Draw + optionally add Gotterdammerung
function s.gotfilter(c)
	return c:IsCode(91148083) and c:IsAbleToHand()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	if Duel.GetFlagEffect(tp,id)>0 and Duel.IsExistingMatchingCard(s.gotfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.gotfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			local code=g:GetFirst():GetCode()
			-- Cannot activate that card for the rest of the turn
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

--Condition: control Aesir
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x4b)
end

--Destroy + apply or set effect
function s.desfilter(c)
	return c:IsSpellTrap() and c:IsDestructable()
end
function s.setfilter(c)
	return c:IsTrap() and c:IsSetCard(0x42) and c:IsSSetable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local typ=tc:GetType()
		if (typ&TYPE_SPELL)==TYPE_SPELL and tc:IsHasType(TYPE_QUICKPLAY) and tc:IsActivatable(tp,true,true) then
			tc:CreateEffectRelation(e)
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
			local te=tc:GetActivateEffect()
			if te then
				local tg=te:GetTarget()
				if not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,0,0) then
					Duel.BreakEffect()
					Duel.ClearTargetCard()
					Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVING,e,REASON_EFFECT,tp,tp,0)
					te:UseCountLimit(tp,1)
					local op=te:GetOperation()
					if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,0,0) end
				end
			end
		elseif (typ&TYPE_TRAP)==TYPE_TRAP and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,67098114),tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SSet(tp,sg)
			end
		end
	end
end
