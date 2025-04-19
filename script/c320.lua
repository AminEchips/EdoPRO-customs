--Darklord Dealings
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={0xef}

-- Cost: send 1 "Darklord" from hand or face-up field to GY
function s.cfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsLocation(LOCATION_MZONE)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

-- Operation: draw 2, then send 1 "Darklord" from hand to GY, or entire hand if none
function s.filter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,2,REASON_EFFECT)==0 then return end
    Duel.BreakEffect()
    local hand=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
    local darks=hand:Filter(s.filter,nil)
    if #darks>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=darks:Select(tp,1,1,nil)
        Duel.SendtoGrave(g,REASON_EFFECT)
    else
        Duel.SendtoGrave(hand,REASON_EFFECT)
    end
end

