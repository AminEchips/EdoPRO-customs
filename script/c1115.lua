--Salamangreat Shrine
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Unaffected by opponent's monster effects (non-FIRE)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_SZONE)
	e0:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
	e0:SetTarget(s.immtg)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)

	--Use a Salamangreat with same name for Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.linkcon)
	e1:SetOperation(s.linkop)
	c:RegisterEffect(e1)

	--Quick Link Summon when opponent activates a non-FIRE monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.qscon)
	e2:SetOperation(s.qsop)
	c:RegisterEffect(e2)
end

function s.immtg(e,c)
	return c:IsSetCard(0x119)
end
function s.efilter(e,te)
	return te:IsActivated() and te:IsActiveType(TYPE_MONSTER) and not te:GetHandler():IsAttribute(ATTRIBUTE_FIRE)
end

function s.linkfilter(c,tp)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsSummonPlayer(tp)
end
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.linkfilter,1,nil,tp)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.linkfilter,nil,tp)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_MATERIAL)
		e1:SetValue(function(c,sc,tp) return c:IsCode(tc:GetCode()) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.qscon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep~=tp and rc:IsOnField() and rc:IsType(TYPE_MONSTER) and not rc:IsAttribute(ATTRIBUTE_FIRE)
end
function s.qsop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)<=0 then return end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(c)
		return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSpecialSummonable(SUMMON_TYPE_LINK)
	end),tp,LOCATION_EXTRA,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc,g)
	end
end
