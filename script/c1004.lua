--Swordsoul Zhan Lu
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x27d} -- Swordsoul
	s.listed_names={68468459} -- Fallen of Albaz

	-- Special Summon this or Token by returning a target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Gain 1200 LP if sent to GY as Synchro Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

-- Effect 1: Return a valid card to Special Summon this or a Token
function s.tgfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x27d) or c:IsRace(RACE_WYRM)
		or c:IsCode(68468459) or (c.ListsCode and c:ListsCode(68468459))) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
			and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
				or Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,4,RACE_WYRM,ATTRIBUTE_WATER,tp))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local c=e:GetHandler()
		local opt=0
		if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,4,RACE_WYRM,ATTRIBUTE_WATER,tp) then
			opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- Choose: 0 = this card, 1 = token
		elseif c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			opt=0
		elseif Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,4,RACE_WYRM,ATTRIBUTE_WATER,tp) then
			opt=1
		end

		if opt==0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)

			-- Restriction: No non-Synchro monsters from Extra Deck
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

-- Effect 2: Gain 1200 LP if used as Synchro Material
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1200)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,1200,REASON_EFFECT)
end
