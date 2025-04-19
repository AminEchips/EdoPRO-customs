--Azazel the Sanctified Darklord
local s,id=GetID()
function s.initial_effect(c)
	--Must be Fusion Summoned
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,313,s.matfilter)
	
	--Set 1 "Darklord" Trap if no Field Spell face-up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	--If tributed or destroyed by battle: destroy 1 Spell/Trap on the field, then draw 1 if it was a Field Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	c:RegisterEffect(e3)
end
s.listed_names={313}
s.listed_series={0xef}

function s.matfilter(c)
	return c:IsSetCard(0xef)
end

--Effect 1
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_FIELD)
end
function s.setfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tribute_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
function s.tribute_filter(c)
	return c:IsSetCard(0xef) and c:IsSummonable(true,nil) or c:IsAbleToGraveAsCost()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g:GetFirst())>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		local tc=Duel.SelectMatchingCard(tp,s.tribute_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			if tc:IsSummonable(true,nil) then
				Duel.Summon(tp,tc,true,nil)
			elseif tc:IsAbleToGraveAsCost() then
				Duel.SendtoGrave(tc,REASON_COST+REASON_RELEASE)
			end
		end
	end
end

--Effect 2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:GetFirst():IsType(TYPE_FIELD) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsType(TYPE_FIELD) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
