--Bystial Blaster Requiem
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x189}

	-- Xyz Summon procedure: 3 Level 8 LIGHT/DARK
	Xyz.AddProcedure(c,s.mfilter,8,3)
	c:EnableReviveLimit()

	-- Alternative Xyz Summon using "Bystial Blaster"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetOperation(s.altop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)

	-- Cannot be banished (if condition met)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.banishcond)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Quick Effect: banish + boost
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

-- LIGHT or DARK
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end

-- "Bystial Blaster" alt summon
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.blastfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.blastfilter(c,xc)
	return c:IsFaceup() and c:IsCode(1059) and c:IsCanBeXyzMaterial(xc)
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectMatchingCard(tp,s.blastfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		local mg=tc:GetOverlayGroup()
		if #mg>0 then
			Duel.Overlay(c,mg)
		end
		c:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(c,Group.FromCards(tc))
	end
end

-- Cannot be banished if 3+ materials or a Fusion material
function s.banishcond(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:GetOverlayCount()>=3 or mg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end

-- Cost: detach 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		and c:GetFlagEffect(id)==0 end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- Prevent reuse next turn (like Mirrorjade)
	local reset=RESET_SELF_TURN
	if Duel.IsTurnPlayer(tp) then reset=RESET_OPPO_TURN end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end

-- Opponent must have monsters on field and ED
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g1>0 and #g2>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_MZONE+LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_EXTRA,1,1,nil)
	if #g1==0 or #g2==0 then return end
	local bg=Group.__add(g1,g2)
	if Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)==2 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local val=0
		for bc in aux.Next(bg) do
			local l=bc:GetLevel()
			local r=bc:GetRank()
			local link=bc:GetLink()
			val=val+(l+r+link)*300
		end
		-- Gain ATK/DEF until end of turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
