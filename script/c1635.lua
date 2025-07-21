--Nordic Relic Guanjefear
--Scripted by Meuh, corrected with Kuibelt logic
local s,id=GetID()
function s.initial_effect(c)
	--Activate: select 1 "Aesir" monster at resolution
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	--The selected monster cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.battletg)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--While you control that monster: "Nordic Relic" cards cannot be destroyed
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

	--Opponent's monster cannot attack during their next turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)

	--Draw 1 card if your "Aesir" monster attacks (once per turn)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1}) -- Only this effect is once per turn
	e5:SetCondition(s.drcon)
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
end

-- Choose 1 "Aesir" monster at resolution
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

-- Targeted "Aesir" monster gains battle protection
function s.battletg(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end

-- Protect face-up "Nordic Relic" cards
function s.relictg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x5042)
end

-- No battle damage from battles involving "Nordic" monsters
function s.nordictg(e,c)
	return c:IsSetCard(0x42)
end

-- Opponent's monster cannot attack during their next turn
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and (d:IsSetCard(0x42) or d:IsSetCard(0x4b))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() or not a:IsFaceup() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3206)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	a:RegisterEffect(e1)
end

-- Draw 1 card if your "Aesir" monster attacks
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
