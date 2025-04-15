-- EN - Contact Neo Space
local s,id=GetID()
s.listed_names={89943723,42015635}

function s.initial_effect(c)
    -- Activate as Field Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Always treated as "Neo Space"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetRange(LOCATION_FZONE+LOCATION_GRAVE)
    e1:SetValue(42015635) -- Neo Space
    c:RegisterEffect(e1)

    -- End Phase effect prevent Neos Fusion from shuffling
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(42015635) -- Same code used in real Neo Space
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    c:RegisterEffect(e2)

    -- Search Neo-Spacian
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- GY recovery
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.addcon)
    e4:SetCost(s.addcost)
    e4:SetTarget(s.addtg)
    e4:SetOperation(s.addop)
    c:RegisterEffect(e4)
end

-- Neo-Spacian fallback list (in case no SetCode in DB)
function s.thfilter(c)
    return c:IsAbleToHand() and (
        c:IsSetCard(0x1f) or
        c:IsCode(80896940,43237273,17955766,44762290,65338781,80344569,00000200)
    )
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- GY condition: not the same turn
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetTurnID() < Duel.GetTurnCount()
end
function s.cfilter(c)
    return c:IsCode(89943723) or (c:IsSetCard(0x1f) and c:IsAbleToGraveAsCost())
end
function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end



