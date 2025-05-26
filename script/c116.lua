--Odd-Eyes Supreme King Gate Magician
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	-- Scale becomes 4 if no "Magician" or "Supreme King" in other PZone
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_LSCALE)
	e0:SetCondition(s.scalecon)
	e0:SetValue(4)
	c:RegisterEffect(e0)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e0b)

	-- Set 1 Trap from GY if monster destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	-- Cannot be Normal Summoned/Set
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e2b)

	-- Custom Special Summon from hand or Extra Deck by tributing 1 "Supreme King Gate" + 1 "Magician" Pendulum
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	e3:SetValue(SUMMON_TYPE_SPECIAL)
	c:RegisterEffect(e3)

	-- Quick Effect: immunity + battle suppression
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.qecon)
	e4:SetOperation(s.qeop)
	c:RegisterEffect(e4)

	-- When destroyed: move to PZone, Set 1 Spell from GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.setpzcon)
	e5:SetTarget(s.setpztg)
	e5:SetOperation(s.setpzop)
	c:RegisterEffect(e5)
end

-- Scale condition
function s.scalecon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(function(c)
		return c:IsType(TYPE_PENDULUM) and (c:IsSetCard(0xf8) or c:IsSetCard(0x98)) -- Supreme King or Magician
	end,tp,LOCATION_PZONE,0,1,e:GetHandler())
end

-- Pendulum: Set 1 Trap from GY
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.SSet(tp,g:GetFirst()) end
end

-- Special Summon procedure
function s.spfilter1(c)
	return c:IsSetCard(0xf8) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
function s.spfilter2(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and c:IsReleasable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	Duel.Release(g1,REASON_COST)
end

-- Quick effect: respond to Spell/Trap with immunity and activation lock
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Immunity to Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,re) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	-- Prevent opponent activations during battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(function(e,re,tp)
		return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
	end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

-- Float to PZone + Set Spell from GY
function s.setpzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.setpzfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.setpztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
			and Duel.IsExistingMatchingCard(s.setpzfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
end
function s.setpzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	local g=Duel.SelectMatchingCard(tp,s.setpzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
