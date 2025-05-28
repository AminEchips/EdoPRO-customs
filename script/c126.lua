--Supreme King Dragon Greedy Venom
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2,s.matfilter2)

	--On Fusion Summon: Add 1 Fusion/Polymerization Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.addcon)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)

	--Board wipe: destroy all monsters except those in Pendulum Zones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetOperation(s.wipeop)
	c:RegisterEffect(e2)

	--Revive during End Phase if destroyed and sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	--Track if sent to GY this turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end

-- Fusion Materials
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsType(TYPE_PENDULUM,fc,sumtype,tp)
end

-- Effect 1: Add Fusion/Polymerization Spell on Fusion Summon
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.addfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.addfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.addfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.addfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

-- Effect 2: Destroy all monsters except Pendulum Zones
function s.wipeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsMonster() and not c:IsLocation(LOCATION_PZONE) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- Effect 3: Register if destroyed this turn
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

-- Effect 3: Revive a Dragon during End Phase
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
