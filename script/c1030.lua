--Despian Lithurgical
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,72272462,s.matfilter)
	-- Must be Fusion Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- Your monsters cannot be destroyed by battle, except by Level 8+ Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)

	-- Main Phase Quick Effect: Target 1 other Level 8+ Fusion; banish opponent’s monsters with less ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	-- Start of Battle Phase: 1 monster loses ATK equal to total ATK of all monsters on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_names={72272462} -- Despian Quaeritis

-- Fusion material: LIGHT or DARK Fusion Monster
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

-- e1: Indestructible by battle except by Level 8+ Fusion Monsters
function s.indval(e,c)
	return not (c:IsType(TYPE_FUSION) and c:IsLevelAbove(8))
end

-- e2: Quick banish during Main Phase
function s.rmfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and c:IsFaceup()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	e:SetLabel(g:GetFirst():GetAttack())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	local g=Duel.GetMatchingGroup(function(c,atk)
		return c:IsFaceup() and c:IsControler(1-tp) and c:IsAttackBelow(atk) and c:IsAbleToRemove()
	end,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- e3: Start of Battle Phase, reduce ATK
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE+LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE+LOCATION_MZONE,LOCATION_MZONE+LOCATION_MZONE,nil)
	local totatk=g:GetSum(Card.GetAttack)
	if totatk==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE+LOCATION_MZONE,LOCATION_MZONE+LOCATION_MZONE,1,1,nil)
	local tc=sg:GetFirst()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-totatk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
