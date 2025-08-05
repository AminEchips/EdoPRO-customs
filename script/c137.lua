--Supreme King Dragon Odd-Eyes Burst Ray
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)

	--Scale boost based on hand size
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_LSCALE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetValue(s.scaleval)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e0b)

	--Special Summon from Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spzcon)
	e1:SetCost(s.spzcost)
	e1:SetTarget(s.spztg)
	e1:SetOperation(s.spzop)
	c:RegisterEffect(e1)

	--Gain ATK and extra attack on Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--Negate opponent’s monsters on attack, then optionally destroy Pendulum
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.ngcon)
	e3:SetTarget(s.ngtg)
	e3:SetOperation(s.ngop)
	c:RegisterEffect(e3)

	--Fusion Summon when destroyed, then place self in Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.fuscon)
	e4:SetTarget(s.fustg)
	e4:SetOperation(s.fusop)
	c:RegisterEffect(e4)

	--Synchro Materials: 1 Tuner + 1+ non-Tuner "Odd-Eyes" monsters
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunction(Card.IsSetCard,0x99),1,99)
	c:EnableReviveLimit()
end

s.listed_series={0x99,0x20f8}

-- Scale increase
function s.scaleval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)
end

-- Special Summon from Pendulum Zone
function s.spzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_SYNCHRO)
		and Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_PENDULUM) end
	local g1=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,1,false,nil,nil,TYPE_SYNCHRO)
	local g2=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,1,false,nil,nil,TYPE_PENDULUM)
	g1:Merge(g2)
	Duel.Release(g1,REASON_COST)
end
function s.spztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Gain ATK and extra attack
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 then
		local atk=Effect.CreateEffect(c)
		atk:SetType(EFFECT_TYPE_SINGLE)
		atk:SetCode(EFFECT_UPDATE_ATTACK)
		atk:SetValue(ct*200)
		atk:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(atk)
	end
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetCode(EFFECT_EXTRA_ATTACK)
	ea:SetValue(1)
	ea:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(ea)
end

-- Negate face-up monsters
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_PENDULUM)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_PENDULUM)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

-- Fusion Summon on destruction
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.fusfilter(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,f)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local pg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_PZONE,0,nil)
		mg:Merge(pg)
		return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	local pg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_PZONE,0,nil)
	mg:Merge(pg)
	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,tp)
		sc:SetMaterial(mat)
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
	-- Place this card in Pendulum Zone
	if c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
