--Reflection of the Branded
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of 2 effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--GY effect: Set itself
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end

s.listed_names={68468459} -- Fallen of Albaz

-- Fusion Summon Filters
function s.fusfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.matfilter(c,e)
	return c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end

-- Destruction cost: tribute a Fusion monster
function s.costfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsReleasable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e)
	local chk2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return chk1 or (chk2 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil)) end
	local opt=0
	if chk1 and chk2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif chk1 then
		opt=0
		Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		opt=1
		Duel.SelectOption(tp,aux.Stringid(id,1))
	end
	e:SetLabel(opt)
	if opt==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,LOCATION_ONFIELD)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		local mat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		local fus=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if #mat==0 or #fus==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=fus:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_MATERIAL)
		local mat2=mat:Select(tp,1,99,nil)
		if #mat2==0 then return end
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local cost=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #cost==0 or Duel.Release(cost,REASON_COST)==0 then return end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
		if #g==2 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

-- GY float effect
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsMonsterEffect()
		and re:GetHandler():IsCode(68468459) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1,{id,1})
		e1:SetTarget(s.settg)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	return chk==0 or e:GetHandler():IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end
