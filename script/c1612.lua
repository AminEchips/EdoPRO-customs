--Verdandi of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	-- 1. On Synchro Summon: Target 1 Nordic Alfar in GY, banish it, then summon up to 2 Tokens
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)

	-- 2. If Loki is Special Summoned while this is in GY: Banish it, draw 2 then discard 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.drcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={67098114} -- Loki, Lord of the Aesir
s.listed_series={0xa042, 0x42} -- Nordic Alfar, Nordic

-- Must be Synchro Summoned
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Target 1 Nordic Alfar in GY
function s.tkfilter(c)
	return c:IsSetCard(0xa042) and c:IsAbleToRemove()
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tkfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1648,0,TYPES_TOKEN,200,300,2,RACE_SPELLCASTER,ATTRIBUTE_DARK) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.tkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	local ct=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct==0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,1648,0,TYPES_TOKEN,200,300,2,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	for i=1,ct do
		local token=Duel.CreateToken(tp,1648)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end

-- If Loki is Special Summoned while this is in GY
function s.lokifilter(c,tp)
	return c:IsFaceup() and c:IsCode(67098114) and c:IsSummonPlayer(tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lokifilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
