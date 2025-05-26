--Performapal Spectral Magician
local s,id=GetID()

function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	-- Always treated as "Predaplant"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(0x10f3) -- Predaplant
	c:RegisterEffect(e0)

	-- Pendulum Effect: Optional activation to boost DARK Pendulum monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.pcon)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)

	-- Monster Effect 1: Special Summon self by targeting DARK, becomes DARK, gain stats if Plant
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Monster Effect 2: Recover from face-up Extra Deck if you control Dragon Fusion
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.recon)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
end

-- PENDULUM EFFECT (manual activation)
function s.pfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	local otherpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not otherpz or not otherpz:IsAttribute(ATTRIBUTE_DARK) then return false end
	return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- MONSTER EFFECT 1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttribute(ATTRIBUTE_DARK) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_DARK) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_MZONE,0,1,1,nil,ATTRIBUTE_DARK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Always become DARK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		-- Gain stats if Plant
		if tc:IsRace(RACE_PLANT) then
			local atk=tc:GetAttack()
			if atk>0 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(atk)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e2)
			end
			local def=tc:GetDefense()
			if def>0 then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				e3:SetValue(def)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e3)
			end
			local lv=tc:GetLevel()
			if type(lv)=="number" and lv>0 then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(lv)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e4)
			end
		end
	end
end

-- MONSTER EFFECT 2 (Extra Deck)
function s.fusionfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON)
end
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_PENDULUM) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_EXTRA)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_PENDULUM)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
