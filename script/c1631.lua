--Jotunheim, Home of the Frost Giants
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate as Field Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Main effect (once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Filter: Field Spells in GY
function s.fieldspellfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end

-- Filter: Valid monsters (no 0 ATK/DEF, face-up)
function s.validmonster(c,tp)
	return c:IsFaceup() and c:GetAttack()>0 and c:GetDefense()>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.validmonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.fieldspellfilter,tp,LOCATION_GRAVE,0,1,nil)
			and g:GetCount()>=2
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.fieldspellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,tp,LOCATION_GRAVE)

	-- Select up to 5 monsters including at least 2 from your field
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,2,5,nil)
	if sg:FilterCount(Card.IsControler,nil,tp)<2 then return end
	Duel.SetTargetCard(sg)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Add Field Spell from GY
	local g=Duel.GetMatchingGroup(s.fieldspellfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=g:Select(tp,1,1,nil)
		if #tg>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
		end
	end

	-- Get targeted monsters
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or #tg<2 or tg:FilterCount(Card.IsControler,nil,tp)<2 then return end
	tg=tg:Filter(Card.IsRelateToEffect,nil,e)

	local sum_atk,sum_def,count=0,0,#tg
	for tc in tg:Iter() do
		sum_atk = sum_atk + tc:GetAttack()
		sum_def = sum_def + tc:GetDefense()
	end
	if count==0 then return end

	local avg_atk=math.floor(sum_atk/count)
	local avg_def=math.floor(sum_def/count)

	for tc in tg:Iter() do
		-- Set ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(avg_atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- Set DEF
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(avg_def)
		tc:RegisterEffect(e2)
	end
end
