--Nordic Relic Guanjefear
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--Activate, select 1 "Aesir" monster at resolution
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)
	--Selected monster cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.battletg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Face-up "Nordic Relic" cards cannot be destroyed by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.relictg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--You take no battle damage from battles involving "Nordic" monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.nordictg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--If opponent's monster attacks your Aesir or Nordic monster, it cannot attack next turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	--Draw 1 if your "Aesir" monster attacks (once per turn)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.drcon)
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
end

-- At resolution, select 1 Aesir monster to grant protection
function s.aesirfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.aesirfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		e:GetHandler():SetCardTarget(sg:GetFirst())
	end
end

-- Effect 1: Protection applies to selected monster
function s.battletg(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end

-- Effect 2: Face-up "Nordic Relic" cards cannot be destroyed
function s.relictg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x5042)
end

-- Effect 3: No battle damage from battles involving "Nordic" monsters
function s.nordictg(e,c)
	return c:IsSetCard(0x42)
end

-- Effect 4: Opponent’s monster cannot attack next turn
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and (d:IsSetCard(0x42) or d:IsSetCard(0x4b))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() or not a:IsFaceup() then return end

	local turn_id=Duel.GetTurnCount()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c==a and Duel.GetTurnCount()~=turn_id
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end

-- Effect 5: Draw if your Aesir monster attacks
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsSetCard(0x4b)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
