--Odd-Eyes Crystalstream Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3,3,s.lcheck)

	--Floating effect on destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--Bonus effect if Link Summoned using Odd-Eyes Pendulum Dragon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.cond_oddeyes)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

--Material check: requires 1 "Odd-Eyes" Pendulum Monster
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(function(c) return c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM,lc,sumtype,tp) end,1,nil)
end

--Float: If destroyed by opponent or battle
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and
		(c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Condition: Was Link Summoned using Odd-Eyes Pendulum Dragon
function s.cond_oddeyes(e)
	return e:GetHandler():GetMaterial():IsExists(Card.IsCode,1,nil,16178681)
end

--Return F/S/X from any GY to Extra Deck, then draw 1 and maybe destroy
function s.tdfilter(c,typ)
	return c:IsType(typ) and c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_GRAVE,0,1,nil,TYPE_FUSION)
			or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
			or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_GRAVE,0,1,nil,TYPE_XYZ)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local types_returned=0

	-- Try to return Fusion
	local fg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,0,1,1,nil,TYPE_FUSION)
	if #fg>0 then g:Merge(fg) types_returned=types_returned+1 end

	-- Try to return Synchro
	local sg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,0,1,1,nil,TYPE_SYNCHRO)
	if #sg>0 then g:Merge(sg) types_returned=types_returned+1 end

	-- Try to return Xyz
	local xg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,0,1,1,nil,TYPE_XYZ)
	if #xg>0 then g:Merge(xg) types_returned=types_returned+1 end

	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
			if types_returned==3 then
				local dg=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #dg>0 then
					Duel.Destroy(dg,REASON_EFFECT)
				end
			end
		end
	end
end
