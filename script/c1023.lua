--Spright Flash
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()

	--On Xyz Summon: choose one effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)

	--Negate in response to Albaz-related effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

s.listed_names={68468459} -- Fallen of Albaz

-- Effect 1 remains unchanged
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	if opt==0 then
		if c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
			local albaz=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(68468459) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if albaz then
				Duel.SpecialSummon(albaz,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	else
		local g=Duel.SelectMatchingCard(tp,function(c) return c:IsType(TYPE_FUSION) and c:IsAbleToRemove() and c:GetLevel()>=4 end,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			local lv=g:GetFirst():GetLevel()
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
				Duel.Draw(tp,math.floor(lv/4),REASON_EFFECT)
			end
		end
	end
end

-- Effect 2: Response negate to Albaz or mentions-Albaz
function s.albaz_related(re)
	local rc=re:GetHandler()
	return rc:IsCode(68468459) or rc:ListsCode(68468459)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not Duel.IsChainDisablable(ev) then return false end
	local ce,cp,cv,cod=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_CHAINING_PLAYER,CHAININFO_CHAINING_TRIGGERING_EFFECT)
	if not ce then return false end
	local prev_chain=ev-1
	if prev_chain<1 then return false end
	local prev_re=Duel.GetChainInfo(prev_chain,CHAININFO_TRIGGERING_EFFECT)
	return prev_re and s.albaz_related(prev_re)
end

function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local bc=e:GetLabelObject()
		if bc then
			local is2=bc:GetLevel()==2 or bc:GetRank()==2 or (bc:IsType(TYPE_LINK) and bc:GetLink()==2)
			if is2 and rc:IsFaceup() and rc:IsRelateToEffect(re) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				rc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				rc:RegisterEffect(e2)
			end
		end
	end
end
