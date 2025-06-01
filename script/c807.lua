--Raidraptor - Evolution Falcon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,73887236,s.ffilter)

	--Attack all Special Summoned monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(s.atkfilter)
	c:RegisterEffect(e1)

	--Set ATK/DEF based on Xyz material's Rank (once per battle)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.statcon)
	e2:SetOperation(s.statop)
	c:RegisterEffect(e2)

	--Negate a card or effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_names={73887236}
s.listed_series={0xba}
function s.ffilter(c)
	return c:IsSetCard(0xba)
end
function s.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.statcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterial():IsExists(s.xyzmatfilter,1,nil)
end
function s.xyzmatfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and not c:IsCode(73887236)
end
function s.statop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mats=c:GetMaterial():Filter(s.xyzmatfilter,nil)
	if #mats>0 then
		local maxrank=0
		for tc in mats:Iter() do
			if tc:GetRank()>maxrank then maxrank=tc:GetRank() end
		end
		if maxrank>0 then
			local atk=maxrank*500
			for _,stat in ipairs({EFFECT_SET_ATTACK_FINAL, EFFECT_SET_DEFENSE_FINAL}) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(stat)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
				c:RegisterEffect(e1)
			end
		end
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
