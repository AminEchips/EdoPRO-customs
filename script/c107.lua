--Odd-Eyes Dimension Dragon
local s,id=GetID()
s.listed_names={13331639,16178681,16494704} -- Z-ARC, Odd-Eyes Pendulum Dragon, Odd-Eyes Advent
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	--Pendulum Effect: revive from GY on Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pcon)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)

	--Special Summon self from hand if you control a Level 4
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)

	--Tribute self: Allow second attack for Z-ARC & Odd-Eyes Pendulum Dragon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.cost)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)

	--Banish from GY: Add Odd-Eyes Advent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+200)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

--Pendulum Effect: If you Ritual Summon an Odd-Eyes monster, revive a Dragon Extra Deck monster from GY
function s.pfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsSetCard(0x99) and c:IsSummonPlayer(tp)
end
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pfilter,1,nil,tp)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if chk==0 then
		return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x99),tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ),tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,0x99),tp,LOCATION_EXTRA,0,1,1,nil)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end



--Special Summon this card from hand if you control a Level 4 monster (Doggy Diver logic)
function s.cfilter(c)
	return c:IsFaceup() and c:GetLevel()==4
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

--Tribute this card: Odd-Eyes Pendulum Dragon and Z-ARC can attack again
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and (c:IsCode(16178681) or c:IsCode(13331639))
	end,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	for tc in g:Iter() do
		-- Grant second attack this Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--Banish from GY to add Odd-Eyes Advent
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,16494704) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,16494704)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
