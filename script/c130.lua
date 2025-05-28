--Odd-Eyes Accel
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x99} -- Odd-Eyes archetype

-- Must control 3 or more Pendulum Monsters in the Monster Zone
function s.pendfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.pendfilter,tp,LOCATION_MZONE,0,nil)>=3
end

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

	local selected={}
	local opcount=0
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		opcount=opcount+1
		selected[opcount]=1
	end
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		opcount=opcount+1
		selected[opcount]=2
	end
	if b3 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		opcount=opcount+1
		selected[opcount]=3
	end

	if opcount==0 then return end

	for i=1,opcount do
		if selected[i]==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		if selected[i]==2 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
		if selected[i]==3 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
