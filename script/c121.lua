--Odd-Eyes Continuum Gazing Magician of Time and Space
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()

	--Fusion Materials: 1 Odd-Eyes + 2 Magician Pendulums with different Scales
	Fusion.AddProcMixN(c,true,true,s.matfilter1,1,s.matfilter2,2)

	--Negate and optionally destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	--Battle destruction: SS + burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Floating
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetTarget(s.float_tg)
	e3:SetOperation(s.float_op)
	c:RegisterEffect(e3)

	--Pendulum OPT limiter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_DRAW)
	e4:SetOperation(function(_,tp) Duel.ResetFlagEffect(tp,id) end)
	Duel.RegisterEffect(e4,0)

	--Pendulum Damage at Damage Step End
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(s.damcon)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)

	--Quick LP Gain
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(function(_,tp) return Duel.GetFlagEffect(tp,id)==0 end)
	e6:SetOperation(s.lpop)
	c:RegisterEffect(e6)
end

--Fusion material filters
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x99,fc,sumtype,tp) -- Odd-Eyes
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x98,fc,sumtype,tp) and c:IsType(TYPE_PENDULUM)
end

--Negate up to 3 and store them for destruction later
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	e:SetLabelObject(g)
	if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then e:SetLabel(1) else e:SetLabel(0) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(Card.IsRelateToEffect,nil,e)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	if e:GetLabel()==1 then
		local tg=Group.CreateGroup()
		for tc in g:Iter() do tg:AddCard(tc) end
		local ef=Effect.CreateEffect(e:GetHandler())
		ef:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ef:SetCode(EVENT_PHASE+PHASE_END)
		ef:SetCountLimit(1)
		ef:SetOperation(function() Duel.Destroy(tg,REASON_EFFECT) end)
		ef:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ef,tp)
	end
end

--Battle destruction effect (non-targeting)
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local atk=g:GetFirst():GetAttack()
		if atk>0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end

--Floating effect
function s.float_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_PZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.float_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
			if #tg>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end

-- Pendulum damage effect
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetFlagEffect(tp,id+1)>0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(tp,id+1)
	if ct>0 then
		Duel.Damage(1-tp,ct*600,REASON_EFFECT)
	end
end

-- Quick LP gain (destroy this)
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Recover(tp,1200,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- Global attack counter like Meteor Rush - Monochroid
if not s.global_check then
	s.global_check=true
	local ge1=Effect.CreateEffect(s)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
	ge1:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(ep,id+1,RESET_PHASE+PHASE_END,0,1) end)
	Duel.RegisterEffect(ge1,0)
end
