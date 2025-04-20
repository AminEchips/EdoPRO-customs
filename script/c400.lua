--Starry Knight Stratael
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Send self + 1 LIGHT monster; send 1 "Starry Knight" from Deck to GY, then add 1 Level 7 LIGHT Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Effect 2: Banish from GY to return 1 banished Fairy to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.rtg)
    e2:SetOperation(s.rop)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}

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
    return c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local th=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #th>0 then
            Duel.SendtoHand(th,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,th)
        end
    end
end

-- Return 1 of your other banished Fairy monsters to the GY
function s.rfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.rfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end
