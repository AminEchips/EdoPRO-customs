--Muspelheim, Birth of Surt
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
	--End Phase effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.endop)
	c:RegisterEffect(e1)

	--If destroyed by monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.ctrlcon)
	e2:SetOperation(s.ctrlop)
	c:RegisterEffect(e2)
end

--Effect 1: End Phase tribute or damage
function s.attackedfilter(c)
	return c:GetAttackAnnouncedCount()>0 and c:IsAttackable()
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local g=Duel.GetMatchingGroup(s.attackedfilter,p,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	--Find highest ATK
	local maxatk=g:GetFirst():GetAttack()
	for tc in g:Iter() do
		if tc:GetAttack()>maxatk then maxatk=tc:GetAttack() end
	end
	local highest=g:Filter(Card.IsAttackAbove,nil,maxatk)
	if #highest>1 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_RELEASE)
		highest=highest:Select(p,1,1,nil)
	end
	local tc=highest:GetFirst()
	if tc then
		if Duel.Release(tc,REASON_EFFECT)>0 then return end
		-- If tribute failed, inflict damage
		Duel.Damage(p,tc:GetAttack(),REASON_EFFECT)
	end
end

--Effect 2: Control 1 opponent's monster
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_EFFECT~=0 and re and re:IsActivated() and re:GetHandler():IsMonster()
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc and Duel.GetControl(tc,tp)~=0 then
		-- Apply restrictions
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
		e3:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_BATTLE end)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
