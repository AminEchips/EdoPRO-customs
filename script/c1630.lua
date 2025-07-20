--Muspelheim, Birth of Surt
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	--End Phase: Tribute or take damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.endop)
	c:RegisterEffect(e1)

	--Store phase when about to leave field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e:SetLabel(Duel.GetCurrentPhase()) end)
	c:RegisterEffect(e2)

	--If destroyed by monster effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.ctrlcon)
	e3:SetOperation(s.ctrlop)
	c:RegisterEffect(e3)
end

--Filter monsters that attacked this turn
function s.attackedfilter(c)
	return c:GetAttackAnnouncedCount()>0 and c:IsAttackable() and c:IsReleasable()
end

--End Phase: Tribute or take damage
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetMatchingGroup(s.attackedfilter,p,LOCATION_MZONE,0,nil)
	if #g==0 then return end

	local maxatk=0
	for tc in g:Iter() do
		if tc:GetAttack()>maxatk then maxatk=tc:GetAttack() end
	end
	local highest=g:Filter(Card.IsAttackAbove,nil,maxatk)
	Duel.Hint(HINT_MESSAGE,p,aux.Stringid(id,1))
	if Duel.SelectYesNo(p,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_RELEASE)
		local sg=highest:Select(p,1,1,nil)
		if #sg>0 then
			Duel.Release(sg,REASON_EFFECT)
			return
		end
	end
	local dmgmon=highest:GetFirst()
	if dmgmon then
		Duel.Damage(p,dmgmon:GetAttack(),REASON_EFFECT)
	end
end

--Check if destroyed by monster effect
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0 and re and re:IsActivated() and re:GetHandler():IsMonster()
end

--Take control on destruction
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc and Duel.GetControl(tc,tp)~=0 then
		-- Only apply restrictions if this wasn't destroyed during Battle Phase
		local wasBattlePhase = e:GetLabel()==PHASE_BATTLE
		if not wasBattlePhase then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
