--Odd-Eyes Arc Phantom Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon: 2 Pendulum Monsters
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2)

	--(Quick Effect) Target 1 face-up S/T your opponent controls; negate its effects until end of turn,
	--then if a card you controlled was destroyed this turn, you can Special Summon 1 Pendulum Monster from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	--If you activate the effect of a Dragon Fusion/Synchro/Xyz Monster (except during the Damage Step):
	--Special Summon 1 Dragon monster with a different card type (Fusion/Synchro/Xyz) from your face-up Extra Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	--Track "a card you controlled was destroyed this turn"
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_DESTROYED)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_PENDULUM)
end

--========================
-- Global destroy check
--========================
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		local p=tc:GetPreviousControler()
		if p==0 or p==1 then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--========================
-- (1) Negate S/T, then optional Pendulum SS from hand if you had a card destroyed this turn
--========================
function s.negfilter(c)
	return c:IsFaceup() and c:IsSpellTrap()
end
function s.pendhandfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	--Negate (disable) until end of turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)

	--Then, if a card you controlled was destroyed this turn, you can SS 1 Pendulum from hand
	if Duel.GetFlagEffect(tp,id)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.pendhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.pendhandfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--========================
-- (2) Trigger on activating Dragon Fusion/Synchro/Xyz monster effect
--========================
local function get_dragon_ex_type(rc)
	if rc:IsType(TYPE_FUSION) then return TYPE_FUSION end
	if rc:IsType(TYPE_SYNCHRO) then return TYPE_SYNCHRO end
	if rc:IsType(TYPE_XYZ) then return TYPE_XYZ end
	return 0
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if rp~=tp then return false end
	if Duel.IsDamageStep() then return false end
	local rc=re:GetHandler()
	return rc and rc:IsMonster() and rc:IsRace(RACE_DRAGON)
		and (rc:IsType(TYPE_FUSION) or rc:IsType(TYPE_SYNCHRO) or rc:IsType(TYPE_XYZ))
end

function s.spfilter2(c,e,tp,ex)
	if not (c:IsMonster() and c:IsRace(RACE_DRAGON)) then return false end
	if not (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ)) then return false end
	if c:IsType(ex) then return false end
	if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ex=get_dragon_ex_type(re:GetHandler())
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,ex)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ex=get_dragon_ex_type(re:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp,ex)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
