--Jotunheim, Home of the Frost Giants
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	-- Activate as Field Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Effect 1: Add 1 Field Spell from GY (if 3+ Field Spells in GY)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Effect 2: Normalize ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.stat_tg)
	e2:SetOperation(s.stat_op)
	c:RegisterEffect(e2)
end

-- Effect 1: Add Field Spell from GY
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_FIELD)>=3
end
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect 2: ATK/DEF Normalization
function s.validmonster(c)
	return c:IsFaceup() and c:GetAttack()>0 and c:GetDefense()>0
end
function s.stat_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.validmonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>=2 and g:FilterCount(Card.IsControler,nil,tp)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,2,5,nil)
	if sg:FilterCount(Card.IsControler,nil,tp)<2 then return end
	Duel.SetTargetCard(sg)
end
function s.stat_op(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or #tg<2 or tg:FilterCount(Card.IsControler,nil,tp)<2 then return end
	tg=tg:Filter(Card.IsRelateToEffect,nil,e)

	local count=#tg
	if count==0 then return end

	local sum_atk,sum_def=0,0
	for tc in tg:Iter() do
		sum_atk = sum_atk + tc:GetAttack()
		sum_def = sum_def + tc:GetDefense()
	end

	local avg_atk=math.floor(sum_atk/count)
	local avg_def=math.floor(sum_def/count)

	for tc in tg:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(avg_atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(avg_def)
		tc:RegisterEffect(e2)
	end
end
