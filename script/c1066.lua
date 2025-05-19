--Icejade Memento
local s,id=GetID()
function s.initial_effect(c)
	s.listed_series={0x16e}
	s.listed_names={07142724} -- Icejade Cenote Enion Cradle

	-- Effect 1: Target 1 banished monster, Special Summon Icejade then that monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Effect 2: GY - Attack Negation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

-- Effect 1
function s.banishfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetAttack()>0
end
function s.icejadefilter(c,e,tp,atk)
	return c:IsSetCard(0x16e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetAttack()<atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(PLAYER_EITHER) and s.banishfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.banishfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.banishfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local atk=tc:GetAttack()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.icejadefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,atk)
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetLocationCount(tc:GetOwner(),LOCATION_MZONE)>0 then
		Duel.SpecialSummon(tc,0,tc:GetOwner(),tc:GetOwner(),false,false,POS_FACEUP)
	end
end

-- Effect 2: Battle negation
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
		and (Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,07142724)
			or Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,07142724))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
