--Despian Dragon King
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMix(c,true,true,68468459,s.matfilter)

	--Immediate copy and resolve: Add/Summon Albaz or archetype monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)

	--If Fusion leaves field due to opponent → blow up Spells/Traps
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desreg)
	c:RegisterEffect(e2)
end
s.listed_names={68468459}
s.listed_series={0x16f} -- Despia

-- Fusion Material must list Albaz
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_FUSION) and c:ListsCode(68468459)
end

-- Immediate Copy Target
function s.copyfilter(c)
	return c:IsType(TYPE_FUSION) and c:ListsCode(68468459) and not c:IsCode(id) and c:IsAbleToExtra()
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.copyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end

	local albaz_code=68468459
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)

	-- Gather all setcodes on the targeted Fusion
	local codes = {}
	for i=1,0xffff do
		if tc:IsSetCard(i) then table.insert(codes,i) end
	end

	-- Build filter
	local g=Duel.GetMatchingGroup(function(card)
		if not card:IsMonster() then return false end
		if card:IsCode(albaz_code) then return true end
		for _,sc in ipairs(codes) do
			if card:IsSetCard(sc) then return true end
		end
		return false
	end,tp,LOCATION_DECK,0,nil)

	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	local sc=sg:GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(c) return ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function(c) Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,1))

	-- Return targeted Fusion to Extra Deck
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

-- Explosion effect trigger
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION)
			and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT) and rp==1-tp
	end,1,nil)
end
function s.desreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+100)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
