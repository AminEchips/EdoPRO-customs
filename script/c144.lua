--Odd-Eyes Wing Dragon Overlord
--Archetypes used: Odd-Eyes (0x99), Clear Wing (0xff)
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum
	Pendulum.AddProcedure(c)
	--Synchro
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	--(P1) P-Zone: If YOU Synchro Summon, SS this, then optional ATK gain equal to original ATK of a chosen Synchro Summoned monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pzcon)
	e1:SetTarget(s.pztg)
	e1:SetOperation(s.pzop)
	c:RegisterEffect(e1)

	--(M1) If Synchro Summoned using a DARK Tuner: SS 1 WIND "Clear Wing" Synchro from GY/Extra (treated as Synchro if a "Clear Wing" was used)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.cwcon)
	e2:SetTarget(s.cwtg)
	e2:SetOperation(s.cwop)
	c:RegisterEffect(e2)

	--(M2) Face-up in Extra Deck: Tribute 1 Tuner + 1 DARK Dragon Pendulum; Special Summon this (tributes after resolution)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.exstg)
	e3:SetOperation(s.exsop)
	c:RegisterEffect(e3)

	--(M3) If destroyed in MZ: you can destroy 1 card in your P-Zone (optional), then place this card in your P-Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+300)
	e4:SetCondition(s.pzsetcon)
	e4:SetOperation(s.pzsetop)
	c:RegisterEffect(e4)
end
s.listed_series={0x99,0xff}
s.listed_names={id}

-- (P1) P-Zone: If YOU Synchro Summon (not in Damage Step): SS this,
-- then you may make 1 other monster you control gain ATK equal to the
-- original ATK of 1 of those Synchro Summoned monsters.
local function isYourSynchro(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return false end
	return eg:IsExists(isYourSynchro,1,nil,tp)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- Special Summon this card from the P-Zone
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<=0 then return end

	-- Optional ATK gain (choose 1 of the Synchro Summoned monsters from this event)
	local g=eg:Filter(isYourSynchro,nil,tp)
	if #g==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	local val=math.max(0,sc:GetBaseAttack())

	-- pick "1 other" face-up monster you control
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectMatchingCard(tp,function(tc) return tc:IsFaceup() and tc~=c end,
	                                  tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	if tc and val>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- ===================================
-- (M1) DARK Tuner + Clear Wing check
-- ===================================
function s.cwcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_SYNCHRO) then return false end
	local mg=c:GetMaterial()
	return mg and mg:IsExists(function(mc) return mc:IsType(TYPE_TUNER) and mc:IsAttribute(ATTRIBUTE_DARK) end,1,nil)
end
function s.cwfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSetCard(0xff) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCountFromEx(tp,tp,nil,e:GetHandler())>0
			and Duel.IsExistingMatchingCard(s.cwfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.cwop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Was a "Clear Wing" monster used as material?
	local usedCW=false
	local mg=c:GetMaterial()
	if mg and mg:IsExists(Card.IsSetCard,1,nil,0xff) then usedCW=true end
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.cwfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if usedCW then
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- =====================================
-- (M2) Face-up in Extra: Tribute & SS it
-- =====================================
function s.tunerfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsReleasableByEffect()
end
function s.darkpenddragon(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
		and c:IsType(TYPE_PENDULUM) and c:IsReleasableByEffect()
end

function s.exstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.darkpenddragon,tp,LOCATION_MZONE,0,1,nil)
	end
	-- tribute happens in operation; SS info declared for clarity
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.exsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Select the two tributes first
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g1==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=Duel.SelectMatchingCard(tp,s.darkpenddragon,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	if #g2==0 then return end
	g1:Merge(g2)

	-- Tribute by effect (NOT a cost)
	if Duel.Release(g1,REASON_EFFECT)~=2 then return end

	-- After tributing, Special Summon this from face-up Extra if possible
	if not (c:IsRelateToEffect(e) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end



-- ==========================================
-- (M3) If destroyed in MZ: go to Pendulum Z
-- ==========================================
function s.pzsetcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.pzsetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- If both P-Zones occupied, you may destroy 1 of them to make space (optional)
	local full=not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if full and Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_PZONE,0,1,1,nil)
		if #dg>0 then Duel.Destroy(dg,REASON_EFFECT) end
	end
	-- Place even if you chose not to destroy (as long as there is room)
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
