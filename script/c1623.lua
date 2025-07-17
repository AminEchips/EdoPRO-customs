--Nordic Relic Sacred Tree Yggdrasil
local s,id=GetID()
function s.initial_effect(c)
	
	-- Activate (Continuous Spell)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	--Additional Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x42)) -- Nordic
	e1:SetCondition(s.nscon)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	--Gain LP if opponent Special Summons while you control an Aesir monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)

	--Place Field Spell from Deck or GY when a Spell/Trap leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.fldcon)
	e3:SetTarget(s.fldtg)
	e3:SetOperation(s.fldop)
	c:RegisterEffect(e3)
end
s.listed_series={0x42,0x4b}

-- Effect 1: Extra Normal Summon condition (Main Phase)
function s.nscon(e)
	return Duel.IsMainPhase()
end

-- Effect 2: Gain LP if opponent Special Summons while you control Aesir
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x4b) -- Aesir
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil):GetFirst()
	if sg and sg:IsFaceup() then
		local val=sg:GetAttack()
		if val>0 then
			Duel.Recover(tp,val,REASON_EFFECT)
		end
	end
end

-- Effect 3: If Spell/Trap leaves field, place a Field Spell from Deck or GY
function s.fldcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsType(TYPE_SPELL+TYPE_TRAP) end,1,nil)
end
function s.fldfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_FZONE)>0
end
function s.fldtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fldfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.fldop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_FZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fldfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
