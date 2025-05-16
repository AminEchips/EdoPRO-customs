--Soriquy the Requiem Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Materials
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- Treated as "Despia"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x166) -- Despia set code
	c:RegisterEffect(e0)

	-- Other Fusion Monsters gain 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)

	-- Change opponent effect + optional Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end

-- Fusion Material Filters
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x166,fc,sumtype,tp) -- Despia
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER+RACE_ILLUSION)
end

-- ATK boost target: Other Fusion Monsters
function s.atktg(e,c)
	return c:IsType(TYPE_FUSION) and c~=e:GetHandler()
end

-- Change opponent effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lv8filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.lv8filter(c)
	return c:IsLevel(8) and c:IsMonster() and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp,code)
	return (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_FIEND)) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lv8filter,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local code=tc:GetOriginalCode()

	-- Replace opponent effect
	Duel.ChangeTargetCard(ev,Group.CreateGroup())
	Duel.ChangeChainOperation(ev,function()
		Duel.SendtoGrave(tc,REASON_EFFECT)

		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,code)
		if #spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=spg:Select(tp,1,1,nil):GetFirst()
			if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
				-- Cannot attack directly
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
			end
		end
	end)
end
