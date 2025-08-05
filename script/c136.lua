--Odd-Eyes Miracle Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)

	--Pendulum Effect: Reveal Dragon, destroy this, place Pendulum from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetTarget(s.pdtg)
	e1:SetOperation(s.pdop)
	c:RegisterEffect(e1)

	--Monster Effect 1: Tribute this; Special Summon Level 7 Odd-Eyes from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Monster Effect 2: Activate in Extra Deck if "Supreme King Dragon" sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.pzcon)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
end

function s.pdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsDestructable()
			and Duel.IsExistingMatchingCard(s.reveal_filter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.pendfilter_any,tp,LOCATION_GRAVE,0,1,nil)
			and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end

function s.pdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.Destroy(c,REASON_EFFECT)==0 then return end

	-- Now that it's destroyed, ask to reveal a Dragon
	if not Duel.IsExistingMatchingCard(s.reveal_filter,tp,LOCATION_HAND,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.reveal_filter,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	local lv=g:GetFirst():GetLevel()
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)

	-- Now find matching Pendulum Monster in GY with that Level
	local tg=Duel.GetMatchingGroup(s.pendfilter,tp,LOCATION_GRAVE,0,nil,lv)
	if #tg>0 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=tg:Select(tp,1,1,nil)
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

function s.reveal_filter(c)
	return c:IsRace(RACE_DRAGON) and not c:IsPublic() and c:IsLevelAbove(1)
end
function s.pendfilter_any(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(1) and not c:IsForbidden()
end
function s.pendfilter(c,lv)
	return c:IsType(TYPE_PENDULUM) and c:IsLevel(lv) and not c:IsForbidden()
end


------------------------------
-- MONSTER EFFECT 1: Tribute to summon Odd-Eyes from Deck
------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

------------------------------
-- MONSTER EFFECT 2: In Extra Deck when "Supreme King Dragon" sent to GY
------------------------------
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsSetCard(0x20f8) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
	end,1,nil)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pendsearch,tp,LOCATION_DECK,0,1,nil) end
end
function s.pendsearch(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevel(10) and c:IsAbleToHand()
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.pendsearch,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
