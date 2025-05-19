--Icejade Actinola
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x16e}
	s.listed_names={07142724} -- Icejade Cenote Enion Cradle

	-- Synchro Summon: 1 Tuner + 1+ non-Tuner WATER monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_WATER),1,99)
	c:EnableReviveLimit()

	-- Effect 1: On Synchro Summon - add Cradle or a card that lists it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Effect 2: During Main Phase - destroy 1 monster you control, opponent's monsters lose 1000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

-- Effect 1: Must be Synchro Summoned
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.thfilter(c)
	return (c:IsCode(07142724) or c:ListsCode(07142724)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect 2: Destroy 1 monster you control (chosen on resolution), then reduce ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(Card.IsDestructable,tp,LOCATION_MZONE,0,nil)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for tc in og:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
