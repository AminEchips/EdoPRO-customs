--Freya, Mother of the Aesir
local s,id=GetID()
-- Initial Effects
function s.initial_effect(c)
	-- THIS IS THE SYNCHRO PROCEDURE YOU ASKED FOR (EXACTLY LIKE ODIN)
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	-- Quick Effect: Negate during your turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- Float during End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3042}

-- Tuner must be "Nordic Ascendant"
function s.tfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x3042,scard,sumtype,tp) or c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
end

-- Negate activation during your turn
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and ep~=tp and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	return true
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.chainlimit)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.chainlimit(e,rp,tp)
	return tp==rp
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

-- Revive if something you controlled was sent to GY this turn by opponent
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.tunercost(c)
	return c:IsSetCard(0x3042) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tunercost,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.tunercost,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

-- Global GY Tracker
if not s.global_check then
	s.global_check=true
	local ge1=Effect.CreateEffect(nil)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_TO_GRAVE)
	ge1:SetOperation(function(_,tp,eg,ep,ev,re,r,rp)
		for tc in eg:Iter() do
			if tc:IsPreviousControler(tp) and tc:IsPreviousPosition(POS_FACEUP)
				and tc:IsPreviousLocation(LOCATION_ONFIELD) and rp~=tp then
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
				break
			end
		end
	end)
	Duel.RegisterEffect(ge1,0)
end
