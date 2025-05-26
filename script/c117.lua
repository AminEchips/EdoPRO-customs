--Performapal Odd-Eyes Curtainmaster
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Materials: 1 Performapal + 1 Fusion OR Synchro OR Xyz OR Ritual Monster
	Fusion.AddProcFun2(c,s.matfilter1,s.matfilter2,true)

	-- Protection from being targeted by Spell/Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(s.protg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	-- ATK Boost effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	-- Float: Add 1 Spell/Trap that mentions Performapal, Odd-Eyes, or Pendulum from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Fusion Material 1: Performapal
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x9f,fc,sumtype,tp)
end
-- Fusion Material 2: Must be Fusion OR Synchro OR Xyz OR Ritual (not all at once)
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp)
		or c:IsType(TYPE_SYNCHRO,fc,sumtype,tp)
		or c:IsType(TYPE_XYZ,fc,sumtype,tp)
		or c:IsType(TYPE_RITUAL,fc,sumtype,tp)
end

-- Protection for other Performapal or Odd-Eyes
function s.protg(e,c)
	return c~=e:GetHandler() and (c:IsSetCard(0x9f) or c:IsSetCard(0x99))
end

-- ATK Boost
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetCount()
	if ct==0 then return end
	local boost=ct*100
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	for tc in g2:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(boost)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end

-- Float condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end

-- Float target filter
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and
		(c:ListsArchetype(0x9f) or c:ListsArchetype(0x99) or c:ListsArchetype(0xf2))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
