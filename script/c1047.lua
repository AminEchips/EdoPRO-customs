--Maximum Spright
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
	--Enable Revive Limit
	c:EnableReviveLimit()

	--Xyz Summon: 3 Level 2 monsters
	Xyz.AddProcedure(c,nil,2,3)
	
	--Also treat Link-2 and Albaz as Level 2
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.xyztg)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 2 or 0 end)
	c:RegisterEffect(e0)

	--ATK/DEF boost + monster effect immunity if Albaz is attached
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.statcon)
	e1:SetValue(s.statval)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	local e1c=Effect.CreateEffect(c)
	e1c:SetType(EFFECT_TYPE_SINGLE)
	e1c:SetCode(EFFECT_IMMUNE_EFFECT)
	e1c:SetCondition(s.statcon)
	e1c:SetValue(s.efilter)
	c:RegisterEffect(e1c)

	--Destroy up to 2 cards (Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	--Search 2 when leaves field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={0x160,0x181,0x17b} -- Branded, Spright, Therion
s.listed_names={68468459} -- Fallen of Albaz

--Allow Link-2 and Albaz to count as Level 2
function s.xyztg(e,c)
	return c:IsCode(68468459) or (c:IsType(TYPE_LINK) and c:GetLink()==2)
end

-- Albaz-based bonus effects
function s.statcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,68468459)
end
function s.statval(e,c)
	return c:GetBaseAttack()
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end

--Destroy 2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsMainPhase()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--Float into search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter(c)
	return (c:IsSetCard(0x160) or c:IsSetCard(0x181) or c:IsSetCard(0x17b)) and c:IsAbleToHand() and c:IsSpellTrap()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
