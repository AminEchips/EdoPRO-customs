--Bystial Blaster Requiem
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x189}

	-- Xyz Summon procedure: 3 Level 8 LIGHT and/or DARK
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

	-- Immunity from banish
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.banishcond)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Quick Effect: banish from opponent's field and Extra Deck, gain ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

-- Material filter: LIGHT or DARK only
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end

-- Alt Xyz condition: using "Bystial Blaster"
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

-- Immunity to banish if 3+ materials or 1 Fusion Monster is a material
function s.banishcond(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return c:GetOverlayCount()>=3 or mg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
end

-- Cost: detach 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Target: Check opponent has at least 1 monster in ED and 1 on field
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g1>0 and #g2>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_MZONE+LOCATION_EXTRA)
end

-- Operation: opponent banishes 1 from field + 1 from ED, gain ATK/DEF
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_EXTRA,1,1,nil)
	if #g1==0 or #g2==0 then return end
	local bg=Group.__add(g1,g2)
	if Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)==2 and c:IsRelateToEffect(e) then
		local val=0
		for bc in aux.Next(bg) do
			local l=bc:GetLevel()
			local r=bc:GetRank()
			local link=bc:GetLink()
			val=val+(l+r+link)*300
		end
		-- Gain ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
