--Darklord Dealings
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
e1:SetCost(s.cost)
e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter1(c)
    return c:IsSetCard(0xef) and c:IsMonster() and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    if #g1==0 or Duel.SendtoGrave(g1,REASON_EFFECT)==0 then return end
    if Duel.Draw(tp,2,REASON_EFFECT)==0 then return end

    Duel.BreakEffect()

    local hand=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if #hand==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil)
    if #g2>0 then
        Duel.SendtoGrave(g2,REASON_EFFECT)
    else
        Duel.SendtoGrave(hand,REASON_EFFECT)
    end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,0xef) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,0xef)
    Duel.SendtoGrave(g,REASON_COST)
end
