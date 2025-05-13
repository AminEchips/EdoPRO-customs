--Springans Chariot
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x158} -- Correct Springans archetype
	s.listed_names={68468459} -- Fallen of Albaz

	-- Special Summon itself from hand if you control an Xyz Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- If certain monster(s) leave the field, gain LP by banishing this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.reccon)
	e2:SetCost(s.reccost)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end

-- Effect 1: Special Summon condition
function s.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Effect 2: Trigger condition when Albaz/mentions-Albaz/Springans Xyz leaves the field
function s.recfilter(c,tp)
	return (c:IsCode(68468459)
		or (c.ListsCode and c:ListsCode(68468459))
		or (c:IsType(TYPE_XYZ) and c:IsSetCard(0x158)))
		and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageCalculated() then return false end
	return eg:IsExists(s.recfilter,1,nil,tp)
end

-- Effect 2: Cost – banish this card
function s.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- Effect 2: Target – store ATK of a valid monster
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.recfilter,nil,tp)
	if #g==0 then return end
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end

-- Effect 2: Recover LP
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	Duel.Recover(tp,atk,REASON_EFFECT)
end
