--Spright Flash
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()

	--On Xyz Summon: choose one effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)

	--GY or banished trigger: revive another banished Xyz + itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.revivetg)
	e2:SetOperation(s.reviveop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end

s.listed_names={68468459} -- Fallen of Albaz

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	if opt==0 then
		-- Detach and summon Albaz
		if c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
			local albaz=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(68468459) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if albaz then
				Duel.SpecialSummon(albaz,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	else
		-- Banish Fusion and draw
		local g=Duel.SelectMatchingCard(tp,function(c) return c:IsType(TYPE_FUSION) and c:IsAbleToRemove() and c:GetLevel()>=4 end,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			local lv=g:GetFirst():GetLevel()
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
				Duel.Draw(tp,math.floor(lv/4),REASON_EFFECT)
			end
		end
	end
end

function s.revfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revivetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
		and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler(),e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_REMOVED)
end
function s.reviveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local tg=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_REMOVED,0,1,1,c,e,tp):GetFirst()
	if not tg then return end
	if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:GetReason()&REASON_MATERIAL>0 and c:GetReason()&REASON_FUSION>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
