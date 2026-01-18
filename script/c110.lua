--Performapal Spectral Magician
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)

	-- Always treated as "Predaplant"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(0x10f3) -- Predaplant
	c:RegisterEffect(e0)

	-- Pendulum Effect: Optional when DARK Pendulum declares attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkoptcon)
	e1:SetTarget(s.atkoptg)
	e1:SetOperation(s.atkopop)
	c:RegisterEffect(e1)

	-- Monster Effect: from hand, destroy 1 DARK monster you control or 1 card in your PZone; choose 1 effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.hdtg)
	e2:SetOperation(s.hdop)
	c:RegisterEffect(e2)
end

-- PENDULUM EFFECT (optional on attack declare)
function s.atkoptcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local otherpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	return tc and tc:IsControler(tp)
		and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsType(TYPE_PENDULUM)
		and otherpz and otherpz:IsAttribute(ATTRIBUTE_DARK)
end
function s.atkoptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.atkopop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- MONSTER EFFECT
function s.hdtgfilter(c,tp)
	return (c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK))
		or (c:IsControler(tp) and c:IsLocation(LOCATION_PZONE))
end

function s.banfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsSetCard(0x9f) or c:IsSetCard(0x99) or c:IsSetCard(0x98)) -- Performapal / Odd-Eyes / Magician
end

function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.hdtgfilter(chkc,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.hdtgfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.hdtgfilter,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- (we don't pre-declare special summon targets because the effect branches)
end

function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if not c:IsRelateToEffect(e) then return end

	-- Build which main options are available
	local canA=true -- "SS this OR place in PZONE" (we'll check the sub-choices after selecting A)
	local canB=Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	local opts={}
	local map={} -- maps displayed index -> main option id (1=A,2=B)
	if canA then
		opts[#opts+1]=aux.Stringid(id,2)
		map[#opts]=1
	end
	if canB then
		opts[#opts+1]=aux.Stringid(id,3)
		map[#opts]=2
	end
	if #opts==0 then return end

	local sel=Duel.SelectOption(tp,table.unpack(opts))
	local choice=map[sel+1]

	if choice==1 then
		-- After destroying, either Special Summon this card OR place it in the Pendulum Zone
		local canSS=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local canPZ=Duel.CheckPendulumZones(tp) and not c:IsForbidden()

		if not canSS and not canPZ then return end

		local sub=0
		if canSS and canPZ then
			sub=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- SS / place in PZONE
		elseif canSS then
			sub=0
		else
			sub=1
		end

		if sub==0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end

	else
		-- Special Summon 1 of your banished Performapal/Odd-Eyes/Magician Pendulum Monsters
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		local sc=g:GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

