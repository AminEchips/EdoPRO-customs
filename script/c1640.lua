--Siegfried of the Nordic Elves
local s,id=GetID()
function s.initial_effect(c)
	--Always treated as multiple archetypes
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(0x3042) -- Nordic Ascendant
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetValue(0xa042) -- Nordic Alfar
	c:RegisterEffect(e0b)
	local e0c=e0:Clone()
	e0c:SetValue(0x6042) -- Nordic Beast
	c:RegisterEffect(e0c)

	--Special Summon from hand & backrow look + control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--If you control Odin, Lord of the Aesir: Look at opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.handcon)
	e2:SetOperation(s.handop)
	c:RegisterEffect(e2)

	--If banished: Add 1 "Nordic" monster with 0 ATK from Deck to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

--e1: Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.aesirfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.aesirfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DIVINE) and c:IsType(TYPE_SYNCHRO)
end
--e1: Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
--e1: Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	--Look at all Set Spells/Traps
	local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_SZONE,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.ConfirmCards(tp,g)
		Duel.ShuffleSetCard(g)
	end
	--If you control an Odin monster, take control of 1 Set Spell/Trap
	if Duel.IsExistingMatchingCard(s.odinfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.takefilter,tp,0,LOCATION_SZONE,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local sg=Duel.SelectMatchingCard(tp,s.takefilter,tp,0,LOCATION_SZONE,1,1,nil,tp)
		if #sg>0 then
			Duel.GetControl(sg:GetFirst(),tp)
		end
	end
end
function s.setfilter(c)
	return c:IsFacedown() and c:IsSpellTrap()
end
function s.takefilter(c,tp)
	return c:IsFacedown() and c:IsSpellTrap() and c:IsControler(1-tp) and c:IsAbleToChangeControler()
end
function s.odinfilter(c)
	return c:IsFaceup() and c:IsCode(93483212,1621,1647)
end

--e2: Look at opponent's hand
function s.handcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.odinfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.handop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
	end
end

--e3: Search 0 ATK Nordic
function s.thfilter(c)
	return c:IsSetCard(0x42) and c:IsAttack(0) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
