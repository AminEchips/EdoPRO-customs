--Bystial Alba-Lubellion
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Summon procedure: Fallen of Albaz + 2 Level 6 Bystial monsters
	Fusion.AddProcMixN(c,true,true,68468459,2,s.matfilter)

	-- (Quick Effect): Tribute 1 Level 8 Fusion Monster; destroy opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	-- If a monster is banished face-up: Special Summon 1 banished "Bystial", then Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.sscon)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)

	-- If this Fusion Summoned card leaves the field by opponent: shuffle all banished LIGHT and DARK monsters into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.retcon)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
end
s.listed_names={68468459} -- Fallen of Albaz
s.listed_series={0x189} -- Bystial

-- Material filter for Fusion
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevel(6) and c:IsSetCard(0x189,scard,sumtype,tp)
end

-- Destroy effect
function s.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsLevel(8) and c:IsReleasable()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
	e:SetLabel(g:GetFirst():GetMaterialCount())
	Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,math.min(ct,#g),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local sg=g:Select(tp,1,ct,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

-- Triggered SS and Synchro
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFaceup,1,nil)
end
function s.ssfilter(c,e,tp)
	return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup()
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_SYNCHRO) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_SYNCHRO)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_SYNCHRO):GetFirst()
			if sc then
				Duel.SynchroSummon(tp,sc,nil)
			end
		end
	end
end

-- Shuffle all banished LIGHT and DARK monsters
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsMonster()
	end,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
