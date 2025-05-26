--Supreme King Gate Reality
local s,id=GetID()
s.listed_names={13331639}
s.listed_series={0x10f8, 0x20f8, 0x10f2, 0x1046, 0x2017, 0x2073}

function s.initial_effect(c)
	Pendulum.AddProcedure(c)

	--Pendulum Effect 1: Z-ARC battle indestructible once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCountLimit(1)
	e1:SetValue(1)
	e1:SetTarget(s.indtg)
	c:RegisterEffect(e1)

	--Pendulum Effect 2: If Z-ARC leaves field, revive a banished Dragon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--Quick Effect: SS from hand, send 4 Dragons from ED
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+100)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_CHAIN_END)
	e3:SetCondition(s.hspcon)
	e3:SetTarget(s.hsptg)
	e3:SetOperation(s.hspop)
	c:RegisterEffect(e3)

	--End Phase: Place Supreme King Gate into Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+200)
	e4:SetTarget(s.pztg)
	e4:SetOperation(s.pzop)
	c:RegisterEffect(e4)

	--If destroyed: place itself in Pendulum Zone
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e5:SetTarget(s.pztg2)
	e5:SetOperation(s.pzop2)
	c:RegisterEffect(e5)
end

--Z-ARC battle indestructible
function s.indtg(e,c)
	return c:IsCode(13331639)
end

--If Z-ARC leaves the field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsCode,1,nil,13331639)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Quick Effect: summon + send 4 archetypes to GY
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re~=nil
end
function s.hspfilter_pen(c) return c:IsSetCard(0x10f2) and c:IsAbleToGrave() end
function s.hspfilter_fus(c) return c:IsSetCard(0x1046) and c:IsAbleToGrave() end
function s.hspfilter_syn(c) return c:IsSetCard(0x2017) and c:IsAbleToGrave() end
function s.hspfilter_xyz(c) return c:IsSetCard(0x2073) and c:IsAbleToGrave() end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.hspfilter_pen,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.hspfilter_fus,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.hspfilter_syn,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.hspfilter_xyz,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,4,tp,LOCATION_EXTRA)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g1=Duel.SelectMatchingCard(tp,s.hspfilter_pen,tp,LOCATION_EXTRA,0,1,1,nil)
		local g2=Duel.SelectMatchingCard(tp,s.hspfilter_fus,tp,LOCATION_EXTRA,0,1,1,nil)
		local g3=Duel.SelectMatchingCard(tp,s.hspfilter_syn,tp,LOCATION_EXTRA,0,1,1,nil)
		local g4=Duel.SelectMatchingCard(tp,s.hspfilter_xyz,tp,LOCATION_EXTRA,0,1,1,nil)
		local g=Group.CreateGroup()
		g:Merge(g1)
		g:Merge(g2)
		g:Merge(g3)
		g:Merge(g4)
		if #g==4 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--Place SK Gate into Pendulum Zone
function s.pzfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--Place itself into Pendulum Zone if destroyed
function s.pztg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.pzop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
