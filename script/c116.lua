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

	-- Special Summon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)

	-- Quick effect: gain immunity + prevent opponent activation during battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.qecon)
	e3:SetOperation(s.qeop)
	c:RegisterEffect(e3)

	-- If destroyed: place in Pendulum Zone, then Set 1 Spell from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.setpzcon)
	e4:SetTarget(s.setpztg)
	e4:SetOperation(s.setpzop)
	c:RegisterEffect(e4)
end

-- Check other PZone for "Magician" or "Supreme King"
function s.scalecon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(function(c)
		return c:IsType(TYPE_PENDULUM) and (c:IsSetCard(0xf8) or c:IsSetCard(0x98))
	end,tp,LOCATION_PZONE,0,1,e:GetHandler())
end

-- Set 1 Trap from GY (Pendulum Effect)
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

-- Special Summon limit (must be Special Summoned by tributing required monsters)
function s.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return se and se:GetHandler():IsLocation(LOCATION_MZONE)
	end
	return false
end

-- Quick Effect trigger: when Spell/Trap is activated
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- Quick Effect operation: gain immunity and limit opponent activation during battle
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Immunity to Spell/Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,re) return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	-- Opponent cannot activate cards/effects during battle with this card
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

-- On destruction: go to Pendulum Zone and Set 1 Spell from GY (no early activation)
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
	if not c:IsRelateToEffect(e) then return end
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setpzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
