--Salamangreat Moonshine Minotaur
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnableCheckReincarnation(c)
	
	-- Place Continuous Spell/Trap from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.placon)
	e1:SetTarget(s.placetg)
	e1:SetOperation(s.placeop)
	c:RegisterEffect(e1)

	-- Reincarnation Summoned: Add back card sent to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.addcon)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)

	-- Battle target: once per turn indestructible unless opponent sends a card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(s.battleop)
	c:RegisterEffect(e3)
end
s.listed_series={0x119}
s.listed_names={38784726,id}

-- Effect 1: Place Spell/Trap
function s.placon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.placefilter(c)
	return c:IsSetCard(0x119) and c:IsContinuousSpellTrap() and not c:IsForbidden()
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

-- Effect 2: Add to hand a card you own sent to GY
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(Card.IsControler,1,nil,tp)
		and not Duel.IsDamageCalculated()
		and c:IsReincarnationSummoned()
		and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	if chk==0 then return eg:IsExists(Card.IsAbleToHand,1,nil) end
	local g=eg:Filter(Card.IsControler,nil,tp):Filter(Card.IsAbleToHand,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- Effect 3: Protection unless opponent sends card to GY
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id+100)==0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(1-tp, aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		else
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			c:RegisterEffect(e2)
		end
		c:RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
	end
end
