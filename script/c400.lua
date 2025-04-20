--Starry Knight Stratael
local s,id=GetID()
function s.initial_effect(c)
    -- Send itself and 1 LIGHT monster; send 1 "Starry Knight" card from Deck to GY, then add 1 Level 7 LIGHT Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Banish to return 1 banished Fairy to GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.rtg)
    e2:SetOperation(s.rop)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}
s.listed_names={id}

function s.cfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.tgfilter(c)
    return c:IsSetCard(0x15b) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.thfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 and g1:GetFirst():IsLocation(LOCATION_GRAVE) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g2>0 then
            Duel.SendtoHand(g2,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g2)
        end
    end
end

function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FAIRY),tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_FAIRY),tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
    end
end
