--Odd-Eyes Dimension Destruction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	--If an "Odd-Eyes" card you control in MZONE or SZONE leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.pzcon)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
end

--(1) On activation: Set 1 "Pendulum" Spell/Trap from Deck or GY
function s.setfilter(c)
	return c:IsSetCard(0xf2) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end

--(2) Trigger condition: an "Odd-Eyes" card you controlled in MZONE/SZONE left the field
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_SZONE+LOCATION_PZONE)
		and c:IsPreviousSetCard(0x99) -- IMPORTANT: works even if it left face-down
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.oe_pendfilter(c,e,tp,code)
	if c:IsCode(code) then return false end
	if not (c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)) then return false end
	if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
	return not c:IsForbidden()
end
function s.oe_extrafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsAbleToGrave()
end

function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local seq=tc:GetSequence() -- 6 or 7 (Pendulum Zones)
	local code=tc:GetCode()

	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- make sure the exact zone we want is free
	if not Duel.CheckLocation(tp,LOCATION_SZONE,seq) then return end

	-- Place 1 "Odd-Eyes" Pendulum Monster with a different name from Deck/face-up Extra/GY into that PZ
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.oe_pendfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp,code)
	local sc=g:GetFirst()
	if not sc or sc:IsForbidden() then return end

	-- Move it to SZONE, then force it into the correct PZ slot (seq 6/7)
	if Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		Duel.MoveSequence(sc,seq)
	else
		return
	end

	-- Then you can send 1 face-up "Odd-Eyes" monster from your Extra Deck to the GY
	if Duel.IsExistingMatchingCard(s.oe_extrafilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,s.oe_extrafilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local mc=sg:GetFirst()
		if mc then
			Duel.SendtoGrave(mc,REASON_EFFECT)
		end
	end
end

