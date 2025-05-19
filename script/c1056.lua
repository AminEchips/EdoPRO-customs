--Swordsoul of Dao
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
	--Special Summon self or summon Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

s.listed_series={0x16d}

function s.sptunerfilter(c)
	return c:IsType(TYPE_TUNER)
end
function s.spswordsoulfilter(c)
	return c:IsSetCard(0x16d)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local hasZone=Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		local canSummonSelf=hasZone and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.sptunerfilter,tp,LOCATION_MZONE,0,1,nil)
		local canDual=hasZone and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SWORDSOUL,0x16d,TYPES_TOKEN|TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) and Duel.IsExistingMatchingCard(s.spswordsoulfilter,tp,LOCATION_MZONE,0,1,nil)
		return canSummonSelf or canDual
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hasZone=Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	local hasTuner=Duel.IsExistingMatchingCard(s.sptunerfilter,tp,LOCATION_MZONE,0,1,nil)
	local hasSS=Duel.IsExistingMatchingCard(s.spswordsoulfilter,tp,LOCATION_MZONE,0,1,nil)
	if not c:IsRelateToEffect(e) then return end

	local opt=0
	if hasTuner and not hasSS then
		opt=0
	elseif hasSS and not hasTuner then
		opt=1
	elseif hasTuner and hasSS then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		return
	end

	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Banish Dao when it leaves the field
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e0:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e0,true)
		if opt==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- Create and summon token
			local token=Duel.CreateToken(tp,TOKEN_SWORDSOUL)
			if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
				-- Banish token when it leaves the field
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				token:RegisterEffect(e1,true)
				-- Restrict Extra Deck Special Summon except Synchro
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e2:SetTargetRange(1,0)
				e2:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO) end)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
				-- Lizard check
				local e3=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
				e3:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e3,tp)
			end
		end
	end
end
