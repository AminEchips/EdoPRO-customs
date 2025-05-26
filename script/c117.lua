--Performapal Odd-Eyes Curtainmaster
local s,id=GetID()
s.listed_series={0xf9,0x99,0xf2} -- Performapal, Odd-Eyes, Pendulum

function s.initial_effect(c)
	-- Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunction(Card.IsSetCard,0xf9), -- Performapal
		function(c) return c:IsSetCard(0x99)
			and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_FUSION)
			or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ)) end
	)

	-- Protection: Your Performapal/Odd-Eyes monsters can't be targeted by Spell/Trap (except this one)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(function(e,re,rp) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	c:RegisterEffect(e1)

	-- ATK Boost: +100 per monster on the field, lasts until end of next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	-- Floating Effect: Add 1 Performapal/Odd-Eyes/Pendulum Spell/Trap from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	e3:SetCountLimit(1,id+100)
	c:RegisterEffect(e3)
end

-- Protection applies to all Performapal/Odd-Eyes monsters except this one
function s.prottg(e,c)
	return c~=e:GetHandler() and (c:IsSetCard(0xf9) or c:IsSetCard(0x99))
end

-- ATK Boost: applies to all monsters you control
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local count=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if count==0 then return end
	local boost = count * 100
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(boost)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

-- Floating: target 1 matching Spell/Trap in GY
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsSetCard(0xf9) or c:IsSetCard(0x99) or c:IsSetCard(0xf2)) and c:IsAbleToHand()
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
