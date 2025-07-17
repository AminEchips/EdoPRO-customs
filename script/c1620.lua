--Loki, Trickster Lord of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--Set "Nordic Relic" from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	--Negate Spell/Trap on resolution (once per turn and optional)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	--Float if sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon_gy)
	e3:SetCost(s.spcost_gy)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Float if banished by opponent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.spcon_rm)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

s.listed_series={0xa042,0x5042,0x42}
s.listed_names={67098114} -- Loki, Lord of the Aesir

function s.tfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0xa042,scard,sumtype,tp) or c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.costfilter(c)
	return c:IsSetCard(0x42) and c:IsAbleToRemoveAsCost()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,5,nil)
	if #rg==0 then return false end
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(#rg)
end

function s.setfilter(c)
	return c:IsSetCard(0x5042) and c:IsSpellTrap() and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #sg<ct then ct=#sg end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local setg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,ct,ct,nil)
	if #setg==0 then return end
	for tc in aux.Next(setg) do
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local stc=Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.NegateEffect(ev)
		Duel.Damage(1-tp,stc*800,REASON_EFFECT)
	end
end

-- Float from GY: triggers, banish as cost
function s.spcon_gy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsReason(REASON_EFFECT+REASON_DESTROY) and c:IsPreviousControler(tp)
end
function s.spcost_gy(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- Float from banish: just condition
function s.spcon_rm(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end

-- Shared target and operation
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(67098114) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
