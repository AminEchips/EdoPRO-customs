--Performapal Quick Show
local s,id=GetID()
function s.initial_effect(c)
	--Always treated as "Speedroid"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(0x2016) -- Speedroid
	c:RegisterEffect(e0)

	--If this card you control would be used as Synchro Material, treat it as a non-Tuner and/or a DARK monster
	--(Engine-friendly implementation: it is treated as a non-Tuner for Synchro Summons, and gains DARK Attribute while on the field.)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1b:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1b)

	--If Normal or Special Summoned: send 1 WIND Tuner from Deck to GY; all opponent monsters lose 500 ATK/DEF, then you can make this card's Level become 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end

s.listed_series={0x9f,0x2016} -- Performapal, Speedroid

function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Send 1 WIND Tuner from Deck to GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

	--All opponent's face-up monsters lose 500 ATK/DEF (until end of turn)
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(og) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end

	--Then you can make this card's Level become 1
	if c:IsFaceup() and c:HasLevel() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
