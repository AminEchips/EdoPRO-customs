--Performapal Joker Archer
local s,id=GetID()

function s.initial_effect(c)
	--Pendulum Attribute
	Pendulum.AddProcedure(c)

	-- Pendulum Effect: Optional once-per-turn effect damage prevention
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.ask_prevention)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)

	--Monster Effect 1: On summon, summon Joker Mage and draw if from hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

	--Monster Effect 2: When sent to GY, Normal Summon 1 Pendulum Monster
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,id+100)
	e6:SetTarget(s.sumtg)
	e6:SetOperation(s.sumop)
	c:RegisterEffect(e6)
end

-- Pendulum Optional Damage Prevention Logic
function s.ask_prevention(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL then return end
	local ex,_,_,cp,val=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if not ex or val<=0 then return end

	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
	local protect_p=(sel==0) and tp or 1-tp
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)

	local eff=Effect.CreateEffect(e:GetHandler())
	eff:SetType(EFFECT_TYPE_FIELD)
	eff:SetCode(id)
	eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	eff:SetTargetRange(1,1)
	eff:SetLabel(cid,protect_p)
	eff:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(eff,tp)

	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.damval(e,re,val,r,rp,rc)
	if (r & REASON_EFFECT)==0 then return val end
	local cid=Duel.GetCurrentChain()
	for _,eff in ipairs({Duel.GetPlayerEffect(e:GetHandlerPlayer(),id)}) do
		local ecid,eplayer=eff:GetLabel()
		if ecid==cid and eplayer==e:GetHandlerPlayer() then
			return 0
		end
	end
	return val
end

-- MONSTER EFFECT 1: Summon Joker Mage & draw if from hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g>0 and g:FilterCount(function(c) return not c:IsType(TYPE_PENDULUM) end,nil)==0
end
function s.spfilter(c,e,tp)
	return c:IsCode(101) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		if tc:IsPreviousLocation(LOCATION_HAND) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

-- MONSTER EFFECT 2: Normal Summon a Pendulum Monster
function s.sumfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.Summon(tp,tc,true,nil) end
end
