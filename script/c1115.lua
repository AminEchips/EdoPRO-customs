--Salamangreat Shrine
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Unaffected by non-FIRE effects (hand and GY)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
	e1:SetTarget(s.immfilter)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	--Reincarnation Link Summon effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.linkcon)
	e2:SetTarget(s.linktg)
	e2:SetOperation(s.linkop)
	c:RegisterEffect(e2)

	--Link Summon after opponent activates non-FIRE monster effect on field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.lscon)
	e3:SetOperation(s.lsop)
	c:RegisterEffect(e3)
end

s.listed_series={0x119}

function s.immfilter(e,c)
	return c:IsSetCard(0x119)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc:IsMonster() and not tc:IsAttribute(ATTRIBUTE_FIRE)
end

-- Link Summon check (Reincarnation Summon)
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c,tp) return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSetCard(0x119) and c:IsControler(tp) end,1,nil,tp)
end
function s.linkfilter(c,sc)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:GetOriginalCode()==sc:GetOriginalCode() and c:IsReleasable()
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c) return c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsControler(tp) end,nil)
	if #g==0 then return end
	local sc=g:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mat=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_MZONE,0,1,1,nil,sc)
	if #mat==0 then return end
	Duel.Release(mat,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local link=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:GetOriginalCode()==mat:GetFirst():GetOriginalCode() and c:IsSpecialSummonable(SUMMON_TYPE_LINK) end,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if link then
		Duel.SpecialSummon(link,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
		link:CompleteProcedure()
	end
end

-- Link Summon on opponent's monster effect activation
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep~=tp and rc:IsLocation(LOCATION_MZONE) and rc:IsMonster() and not rc:IsAttribute(ATTRIBUTE_FIRE)
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,nil)
	if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_EXTRA,0,1,nil) and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local link=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if link then
			Duel.SpecialSummon(link,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
			link:CompleteProcedure()
		end
	end
end
