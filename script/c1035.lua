--Bloom of Despia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon
	Link.AddProcedure(c,nil,3,3,s.matfilter,aux.Stringid(id,0))
	
	--Synchro Summon from GY using banished monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.lkcon)
	e1:SetTarget(s.sytg)
	e1:SetOperation(s.syop)
	c:RegisterEffect(e1)

	--Negate effects if only LIGHT and DARK were used
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={0x166} -- Despia

function s.matfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end

-- Link Summoned check
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Synchro Summon from GY/banished
function s.synfilter(c)
	return c:IsSetCard(0x166) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.tunerfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsLevel(4) and c:IsAbleToRemoveAsCost()
end
function s.synchk(g,e,tp)
	local total=g:GetSum(Card.GetLevel)
	return Duel.IsExistingMatchingCard(s.synchk2,tp,LOCATION_EXTRA,0,1,nil,e,tp,total)
end
function s.synchk2(c,e,tp,lv)
	return c:IsType(TYPE_SYNCHRO) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:GetLevel()==lv
end
function s.sytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_GRAVE,0,nil)
		local t=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_GRAVE,0,nil)
		if #g<1 or #t<1 then return false end
		g:Merge(t)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.synchk,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_GRAVE,0,nil)
	g1:Merge(g2)
	local sg=aux.SelectUnselectGroup(g1,e,tp,2,2,s.synchk,1,tp,HINTMSG_REMOVE)
	if #sg~=2 then return end
	local lv=sg:GetSum(Card.GetLevel)
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL)==2 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synchk2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
		if sc then
			sc:SetMaterial(nil)
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end

-- Negate effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return mg:FilterCount(function(tc) return tc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) end,nil)==#mg
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(function(tc)
		return tc:IsFaceup() and not c:IsHasCardTarget(tc)
	end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		-- Negate effect
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	-- Gain 500 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e3)
end
