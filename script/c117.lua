--Performapal Odd-Eyes Curtainmaster
local s,id=GetID()
s.listed_series={0x9f,0x99,0xf2}

function s.initial_effect(c)
	-- Fusion Summon Procedure (Mirrorjade-style)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunction(Card.IsSetCard,0x9f), -- Performapal
		s.fusmat2
	)
end

function s.fusmat2(c,fc,sumtype,tp)
	return c:IsSetCard(0x99,fc,sumtype,tp) and (
		c:IsType(TYPE_RITUAL,fc,sumtype,tp)
		or c:IsType(TYPE_FUSION,fc,sumtype,tp)
		or c:IsType(TYPE_SYNCHRO,fc,sumtype,tp)
		or c:IsType(TYPE_XYZ,fc,sumtype,tp)
	)
end


	-- Protection: Other Performapal and Odd-Eyes monsters can't be targeted by Spell/Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)

	-- ATK Boost based on number of monsters on field, lasts until end of next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	-- Floating: Add 1 Performapal/Odd-Eyes/Pendulum Spell/Trap from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	e3:SetCountLimit(1,id+100)
	c:RegisterEffect(e3)
end

-- Second Fusion Material: Odd-Eyes Ritual/Fusion/Synchro/Xyz
function s.oddmatfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x99,fc,sumtype,tp)
		and (c:IsType(TYPE_RITUAL,fc,sumtype,tp)
			or c:IsType(TYPE_FUSION,fc,sumtype,tp)
			or c:IsType(TYPE_SYNCHRO,fc,sumtype,tp)
			or c:IsType(TYPE_XYZ,fc,sumtype,tp))
end

-- Protection: applies to all Performapal and Odd-Eyes monsters except this one
function s.prottg(e,c)
	return c~=e:GetHandler() and (c:IsSetCard(0x9f) or c:IsSetCard(0x99))
end
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- ATK Boost: +100 per monster on field, for 2 turns (end of next turn)
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct==0 then return end
	local boost = ct * 100
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(boost)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

-- Floating condition: destroyed by battle or card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end

-- Floating target: 1 Performapal/Odd-Eyes/Pendulum Spell/Trap in GY
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsSetCard(0x9f) or c:IsSetCard(0x99) or c:IsSetCard(0xf2))
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
