--Fiery Armageddon of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--Negate activation, send all to GY, lock SS (Once per Duel)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- once per Duel
	c:RegisterEffect(e1)

	--SS highest ATK in GY next Standby
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1}) -- once per turn
	e2:SetCondition(s.sscon)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
end

-- IDs
local odins={93483212,1621,1647}
local thors={30604579,1619}
local lokis={67098114,1620}

-- Check if 3 different Aesirs (1 of each god) are on field
function s.aesircheck(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local has_odin=false
	local has_thor=false
	local has_loki=false
	for tc in g:Iter() do
		local code=tc:GetOriginalCode()
		if not has_odin and s.list_has(odins,code) then has_odin=true end
		if not has_thor and s.list_has(thors,code) then has_thor=true end
		if not has_loki and s.list_has(lokis,code) then has_loki=true end
	end
	return has_odin and has_thor and has_loki
end
function s.list_has(list,code)
	for _,v in ipairs(list) do
		if v==code then return true end
	end
	return false
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsChainNegatable(ev) and s.aesircheck(tp)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- no cost, just restrict once per Duel
	return true
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
		-- Cannot Special Summon for rest of turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

-- Standby Phase trigger
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,0,nil,e,0,tp,false,false)
	if #g==0 then return end
	local maxatk=-1
	local target=nil
	for tc in g:Iter() do
		local atk=tc:GetAttack()
		if atk>maxatk then
			maxatk=atk
			target=tc
		end
	end
	if target then
		Duel.SpecialSummon(target,0,tp,tp,false,false,POS_FACEUP)
	end
end
