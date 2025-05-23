--Despian Lithurgical
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,72272462,s.matfilter)

	-- Battle Protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)

	-- Main Phase Quick Effect: Banish opponent's monsters with less ATK than a targeted L8+ Fusion
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.mainphasecon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	-- Quick Effect: Choose 1 monster, set its ATK to 0 (non-targeting)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_BATTLE_START+TIMING_BATTLE_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.zeroatktg)
	e3:SetOperation(s.zeroatkop)
	c:RegisterEffect(e3)
end

s.listed_names={72272462} -- Despian Quaeritis

-- Fusion Material: LIGHT or DARK Fusion Monster
function s.matfilter(c,fc,st,tp)
	return c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

-- e1: Battle Protection
function s.indval(e,c)
	return not (c:IsType(TYPE_FUSION) and c:IsLevelAbove(8))
end

-- e2: Banish if opponent's monster has less ATK than targeted L8+ Fusion
function s.mainphasecon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.rmfilter(c,e,tp,handler)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and c~=handler
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,e,tp,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	e:SetLabel(g:GetFirst():GetAttack())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	local g=Duel.GetMatchingGroup(function(c,atk)
		return c:IsFaceup() and c:IsControler(1-tp) and c:GetAttack()<atk and c:IsAbleToRemove()
	end,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

-- e3: Quick non-targeting ATK to 0 for 1 monster
function s.atk0filter(c)
	return c:IsFaceup() and c:GetAttack()>0 and not (c:IsType(TYPE_FUSION) and c:IsLevelAbove(8))
end
function s.zeroatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.atk0filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0)
end
function s.zeroatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.atk0filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if not tc then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
