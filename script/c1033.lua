--Soriquy the Requiem Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion materials: 1 "Despia" + 1 Spellcaster or Illusion
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- Treated as "Despia"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x166) -- Despia set code
	c:RegisterEffect(e0)

	-- Fusion Monsters you control gain 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsType(TYPE_FUSION) end)
	e1:SetValue(500)
	c:RegisterEffect(e1)

	-- Quick Effect: Change opponent's monster effect + Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- Fusion requirements
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x166,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER|RACE_ILLUSION)
end

-- Condition: When opponent activates a monster effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
end

-- Target: Check that the opponent controls a Level 8 monster & you have a summonable target
function s.filter_tg(c)
	return c:IsLevel(8) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp,code)
	return (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_FIEND)) and not c:IsCode(code)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToHand())
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter_tg,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end

-- Operation: Replace opponent effect, send Level 8 monster, then Special Summon
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)

	local g=Duel.SelectMatchingCard(tp,s.filter_tg,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	-- Change effect to "Send that monster"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(function(_,_,_,_,_,_,ev2)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)

	-- Optional: Special Summon
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsPreviousControler(1-tp) then
		local code=tc:GetOriginalCode()
		local spc=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,code)
		if #spc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=spc:Select(tp,1,1,nil):GetFirst()
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
				-- Cannot attack directly this turn
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e2)
			end
		end
	end
end
