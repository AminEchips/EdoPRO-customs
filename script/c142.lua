--Odd-Eyes Wing Zero Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Procedure
	Pendulum.AddProcedure(c)
	
	--Pendulum Effect: Add "Predaplant", "Speedroid", or "The Phantom Knights" from Deck to hand, then banish this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pcon)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)

	--Monster Effect: Quick, destroy 2 in Pendulum Zone, place this from hand or GY in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.mcon)
	e2:SetCost(s.mcost)
	e2:SetTarget(s.mtg)
	e2:SetOperation(s.mop)
	c:RegisterEffect(e2)
end

--List archetypes for deck filtering
s.listed_series={0x10f3,0x2016,0x10db}

--Pendulum Effect

function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.thfilter(c)
	return (c:IsSetCard(0x10f3) or c:IsSetCard(0x2016) or c:IsSetCard(0x10db)) and c:IsAbleToHand()
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and c:IsAbleToRemove()
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
			Duel.ConfirmCards(1-tp,g)
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--Monster Effect

function s.mcon(e,tp,eg,ep,ev,re,r,rp)
	-- Not needed unless you want special restrictions
	return true
end
function s.pzfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_PZONE) and c:IsDestructable()
end
function s.mcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_PZONE,0,2,nil)
	end
end
function s.mtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_PZONE,0,2,nil)
	end
	local g=Duel.GetMatchingGroup(s.pzfilter,tp,LOCATION_PZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.mop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.pzfilter,tp,LOCATION_PZONE,0,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,2,2,nil)
		if Duel.Destroy(dg,REASON_EFFECT)==2 and c:IsRelateToEffect(e) then
			if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
