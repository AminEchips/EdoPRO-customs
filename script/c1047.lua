--Maximum Spright
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
	--Xyz Summon procedure: 3 monsters, allow Albaz/Link-2 substitution
	aux.AddXyzProcedureCustom(c,s.matfilter,nil,3,3,s.xyzcheck)
	c:EnableReviveLimit()

	--ATK/DEF boost + immunity if "Fallen of Albaz" is material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetCondition(s.statcon)
	e0:SetValue(s.statval)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e0b)
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetCode(EFFECT_IMMUNE_EFFECT)
	e0c:SetCondition(s.statcon)
	e0c:SetValue(s.efilter)
	c:RegisterEffect(e0c)

	--Destroy up to 2 cards (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	--Floating search effect when leaves field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={0x160,0x181,0x17b} -- Branded, Spright, Therion
s.listed_names={68468459} -- Fallen of Albaz

-- Xyz Material Conditions
function s.matfilter(c)
	return c:IsLevel(2) or c:IsCode(68468459) or (c:IsType(TYPE_LINK) and c:GetLink()==2)
end
function s.xyzcheck(g,tp,xyz)
	if #g~=3 then return false end
	local albaz=g:FilterCount(Card.IsCode,nil,68468459)
	local link2=g:FilterCount(function(c) return c:IsType(TYPE_LINK) and c:GetLink()==2 end,nil)
	local level2=g:FilterCount(function(c) return c:IsLevel(2) and not c:IsType(TYPE_LINK) and not c:IsCode(68468459) end,nil)
	return albaz<=1 and link2<=1 and (albaz + link2 + level2)==3
end

-- ATK/DEF boost + immunity
function s.statcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,68468459)
end
function s.statval(e,c)
	return c:GetBaseAttack()
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end

-- Destroy effect
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
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- Float effect
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
