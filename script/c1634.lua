--Nordic Relic Andvaranaut
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Continuous Trap)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Effect 1: Burn damage when "Nordic" Tuner is banished for "Aesir" effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(3,{id,0})
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)

	--Effect 2: Banish this + 1 Nordic Relic to destroy a card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

--Check if a Nordic Tuner was banished for an Aesir effect
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x4b) and eg:IsExists(s.tunerfilter,1,nil)
end
function s.tunerfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSetCard(0x42) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc and tc:IsOnField() and tc:GetAttack()>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(math.floor(tc:GetAttack()/2))
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(tc:GetAttack()/2))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc or tc:GetAttack()==nil then return end
	Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
end

--Effect 2: Destroy card from GY
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x4b),tp,LOCATION_MZONE,0,1,nil)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and
		Duel.IsExistingMatchingCard(s.relicfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.relicfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.relicfilter(c)
	return c:IsSetCard(0x5042) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
