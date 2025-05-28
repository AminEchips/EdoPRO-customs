--Odd-Eyes Accel
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x99}

-- Check condition for multiple effect activation
function s.pendfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.has3Pendulums(tp)
	return Duel.GetMatchingGroupCount(s.pendfilter,tp,LOCATION_MZONE,0,nil)>=3
end

-- Filters
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pzfilter(c)
	return c:IsSetCard(0x99) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b3=Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 or b3 end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b3=Duel.IsPlayerCanDraw(tp,1)
	if not (b1 or b2 or b3) then return end

	local multi = s.has3Pendulums(tp)
	local done1, done2, done3 = false, false, false

	-- Always allow one effect
	local opt = {}
	if b1 then table.insert(opt, aux.Stringid(id,0)) end
	if b2 then table.insert(opt, aux.Stringid(id,1)) end
	if b3 then table.insert(opt, aux.Stringid(id,2)) end

	local sel = Duel.SelectOption(tp,table.unpack(opt))
	local trueIdx = 0
	for i=0,2 do
		if (i==0 and b1) or (i==1 and b2) or (i==2 and b3) then
			if trueIdx==sel then sel=i break end
			trueIdx=trueIdx+1
		end
	end

	if sel==0 then
		done1=true
	elseif sel==1 then
		done2=true
	else
		done3=true
	end

	-- Additional choices if allowed
	if multi then
		if not done1 and b1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then done1=true end
		if not done2 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then done2=true end
		if not done3 and b3 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then done3=true end
	end

	-- Resolve effects
	if done1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		end
	end

	if done2 then
		if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			if #g>0 then
				Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end

	if done3 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
