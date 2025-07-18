--Vanaheim, Birth of Freya
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Protect Freya
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.prottg)
	e1:SetOperation(s.protop)
	c:RegisterEffect(e1)

	--Float into Baldur
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.baldcon)
	e2:SetOperation(s.baldop)
	c:RegisterEffect(e2)
end

-- Freya protection target
function s.freya_filter(c)
	return c:IsFaceup() and c:IsCode(1622)
end
function s.prottg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.freya_filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.freya_filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.freya_filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,0,g,1,0,0)
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_REMOVE)
		tc:RegisterEffect(e3)
	end
end

-- Destroy and summon Baldur
function s.baldfilter(c)
	return (c:IsType(TYPE_FIELD) and c:IsLocation(LOCATION_FZONE))
		or (c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup())
end
function s.baldfilter2(c)
	return c:IsCode(1616) and ((c:IsLocation(LOCATION_EXTRA) and not c:IsFacedown()) or c:IsLocation(LOCATION_GRAVE))
end
function s.baldcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsPreviousLocation(LOCATION_ONFIELD)
			and (c:GetPreviousTypeOnField() & (TYPE_SPELL+TYPE_TRAP)) ~= 0
			and c:GetPreviousControler() == tp
	end,1,nil)
	and Duel.IsExistingMatchingCard(s.baldfilter,tp,LOCATION_ONFIELD,0,1,nil)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.baldfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil)
end

function s.baldop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.baldfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			local sc=Duel.SelectMatchingCard(tp,s.baldfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil):GetFirst()
			if sc then
				sc:SetMaterial(nil)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
