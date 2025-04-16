--Elemental HERO Neos Future
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,3,3) -- dynamically validated below

	--Custom Contact Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.sprcon)
	e0:SetOperation(s.sprop)
	c:RegisterEffect(e0)

	--Destroy 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	--Return to Extra Deck replacement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end

-- Fusion Material Filter
function s.matfilter(c,fc,sub,mg,sg)
	if not c:IsMonster() then return false end
	if c:IsCode(89943723) then return true end -- Elemental HERO Neos
	if c:IsType(TYPE_FUSION) and c:ListsCode(89943723) then return true end
	if c:IsSetCard(0x1f) then return true end -- Neo-Spacian
	return false
end

-- Special Summon condition (Contact Fusion)
function s.sprfilter(c)
	return c:IsAbleToDeckOrExtraAsCost() and (c:IsCode(89943723) or c:IsType(TYPE_FUSION) and c:ListsCode(89943723) or c:IsSetCard(0x1f))
end
function s.groupcheck(g)
	local count_neos=0
	local count_neospacian=0
	for tc in aux.Next(g) do
		if tc:IsCode(89943723) or (tc:IsType(TYPE_FUSION) and tc:ListsCode(89943723)) then
			count_neos=count_neos+1
		elseif tc:IsSetCard(0x1f) then
			count_neospacian=count_neospacian+1
		end
	end
	return count_neos==1 and (count_neospacian==2 or count_neospacian==4)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(s.groupcheck,3,5)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.groupcheck,false,3,5)
	if not sg then return end
	c:SetMaterial(sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-- Destroy 1 card
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetMaterialCount()==5 -- special summoned with 4 Neo-Spacian monsters
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- Return to Extra Deck when leaving field
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT+REASON_DESTROY) then
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
