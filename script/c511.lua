--Altergeist Bladelevia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Spellcaster monsters
	Link.AddProcedure(c,nil,2,nil,s.matcheck)
	
	--Gain ATK for each monster it points to
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	--Inflict piercing
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)

	--Tribute to draw and send S/T
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end

s.listed_series={0x103}

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
end

function s.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end

-- Cost: Tribute 1 "Altergeist"
function s.cfilter(c)
	return c:IsSetCard(0x103) and c:IsReleasable()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end

-- Draw 1
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc and dc:IsSetCard(0x103) and Duel.GetMatchingGroupCount(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)>0 then
		Duel.ConfirmCards(1-tp,dc)
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	else
		Duel.ShuffleHand(tp)
	end
end

