--Salamangreat Shrine
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--Reincarnation Link Summon effect (same as Salamangreat Sanctuary)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.reinclinkcon)
	e2:SetTarget(s.reinclinktg)
	e2:SetOperation(s.reinclinkop)
	e2:SetValue(SUMMON_TYPE_LINK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(0x119) and c:IsLinkMonster() end)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)

	--Protection for "Salamangreat" monsters in hand and GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
	e4:SetTarget(function(e,c) return c:IsSetCard(0x119) end)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)

	--Quick Link Summon if opponent activates a non-FIRE monster effect on field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.lkcon)
	e5:SetOperation(s.lkop)
	c:RegisterEffect(e5)
end

function s.efilter(e,te)
	local c=te:GetHandler()
	return c:IsMonster() and not c:IsAttribute(ATTRIBUTE_FIRE)
end

--Reincarnation Link Summon copied from Salamangreat Sanctuary
function s.reincmatfilter(c,lc,tp)
	return c:IsFaceup() and c:IsLinkMonster()
		and c:IsSummonCode(lc,SUMMON_TYPE_LINK,tp,lc:GetCode()) and c:IsCanBeLinkMaterial(lc,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0
end
function s.reinclinkcon(e,c,must,g,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	return ((#mustg==1 and s.reincmatfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
		and not Duel.HasFlagEffect(tp,id)
end
function s.reinclinktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	if #mustg>0 then
		if #mustg>1 then return false end
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.reinclinkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	Duel.Hint(HINT_CARD,0,id)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL|REASON_LINK)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end

--Effect: Triggered Link Summon if opponent activates non-FIRE monster on field
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==1-tp and rc:IsLocation(LOCATION_MZONE) and rc:IsMonster() and not rc:IsAttribute(ATTRIBUTE_FIRE)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(function(c) return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeLinkMaterial() end,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local sg=Duel.GetMatchingGroup(aux.LinkSummonFilter(nil),tp,LOCATION_EXTRA,0,nil)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
	end
end
