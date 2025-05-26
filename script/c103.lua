--Odd-Eyes Luster Silver Dragon
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	--Pendulum Effect: Boost ATK or DEF if Odd-Eyes Synchro is attacked
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	--Monster Effect: Protect other Odd-Eyes from monster targeting
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.prottg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	--All Odd-Eyes monsters do piercing damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.piercetg)
	c:RegisterEffect(e3)

	--Battle damage trigger: Special Summon a Level 7 from GY or face-up Pendulum from ED
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	e4:SetCountLimit(1,id)
	c:RegisterEffect(e4)
end

--Pendulum Condition: Odd-Eyes Synchro targeted for attack
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsControler(tp) and bc:IsType(TYPE_SYNCHRO) and bc:IsSetCard(0x99)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	local atk=Duel.GetAttacker()
	if not bc or not atk or not atk:IsRelateToBattle() then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local def=atk:GetDefense()
		local opt=Duel.SelectOption(tp,1210,1211) -- Choose ATK or DEF
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if opt==0 then
			e1:SetCode(EFFECT_UPDATE_ATTACK)
		else
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
		end
		e1:SetValue(def)
		bc:RegisterEffect(e1)
	end
end

--Protect other Odd-Eyes monsters from being targeted
function s.prottg(e,c)
	return c:IsSetCard(0x99) and c~=e:GetHandler()
end

--All Odd-Eyes monsters gain piercing
function s.piercetg(e,c)
	return c:IsSetCard(0x99)
end

--On battle damage, Special Summon a Level 7 monster from GY or Extra Deck
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
