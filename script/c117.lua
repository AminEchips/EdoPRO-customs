--Performapal Odd-Eyes Curtainmaster
local s,id=GetID()
s.listed_series={0x9f,0x99,0xf2} -- Performapal, Odd-Eyes, Pendulum

function s.initial_effect(c)
	-- Fusion Summon procedure: 1 Performapal + 1 Fusion/Synchro/Xyz/Ritual
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunctionEx(Card.IsSetCard,0x9f), -- Performapal
		aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL)
	)

	-- Protection from Spell/Trap targeting (except this card)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.prottg)
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)

	-- ATK boost: +100 per monster on the field, lasts until end of next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	-- Floating: add 1 Performapal/Odd-Eyes/Pendulum Spell/Trap from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	e3:SetCountLimit(1,id+100)
	c:RegisterEffect(e3)
end

-- Protection: all other Performapal monsters
function s.prottg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x9f)
end
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- ATK boost: 100 × total monsters, lasts 2 turns
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local count=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if count==0 then return end
	local atk=count*100
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

-- Floating effect: add Spell/Trap to hand
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
