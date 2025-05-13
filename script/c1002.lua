--Spright Cherry
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x28d} -- Spright
	s.listed_names={68468459} -- Fallen of Albaz

	-- Special Summon itself from hand if condition is met
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- Send self to GY when monster is Special Summoned from hand to trigger one of two effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.trigcon)
	e2:SetCost(s.trigcost)
	e2:SetTarget(s.trigtg)
	e2:SetOperation(s.trigop)
	c:RegisterEffect(e2)
end

-- Special Summon procedure: control Level/Link 2 monster OR Fallen of Albaz (field or GY)
function s.spfilter(c)
	return c:IsFaceup() and (c:IsLevel(2) or c:IsLink(2)) or c:IsCode(68468459)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end

-- Trigger when a monster is Special Summoned from the hand
function s.trigfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.trigcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil,tp)
end
function s.trigcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.trigtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.trigop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local opt=0
	local lv2_available=g:IsExists(Card.IsLevelAbove,1,nil,1)
	local xyz_available=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_XYZ)
	if lv2_available and xyz_available then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif lv2_available then
		opt=0
	elseif xyz_available then
		opt=1
	else return end

	if opt==0 then
		-- Level 2 effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		-- Xyz Summon effect
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(aux.XyzSummonableFilter,nil,tp,LOCATION_EXTRA,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.XyzSummon(tp,sc)
		end
	end
end

