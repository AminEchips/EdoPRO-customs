--Performapal Odd-Eyes Curtainmaster
local s,id=GetID()
s.listed_series={0xf9,0x99,0xf2} -- Performapal, Odd-Eyes, Pendulum

function s.initial_effect(c)
	-- Fusion summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- Protection: cannot be targeted by Spell/Trap effects (except this one)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(function(e,re,rp) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	c:RegisterEffect(e1)

	-- ATK boost
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

-- Fusion material: Performapal monster
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0xf9,fc,sumtype,tp)
end

-- Fusion material: Odd-Eyes Ritual/Fusion/Synchro/Xyz
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x99,fc,sumtype,tp) and (
		c:IsType(TYPE_RITUAL,fc,sumtype,tp) or
		c:IsType(TYPE_FUSION,fc,sumtype,tp) or
		c:IsType(TYPE_SYNCHRO,fc,sumtype,tp) or
		c:IsType(TYPE_XYZ,fc,sumtype,tp)
	)
end

-- Protection effect: applies to all other Performapal and Odd-Eyes monsters
function s.prottg(e,c)
	return c~=e:GetHandler() and (c:IsSetCard(0xf9) or c:IsSetCard(0x99))
end

-- ATK boost based on number of monsters on field
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct==0 then return end
	local atk=ct*100
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

-- Floating condition: destroyed by battle or card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end

-- Floating target: Performapal/Odd-Eyes/Pendulum Spell/Trap
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsSetCard(0xf9) or c:IsSetCard(0x99) or c:IsSetCard(0xf2))
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
