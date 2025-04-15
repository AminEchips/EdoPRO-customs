-- EN - Contact Neo Space
local s,id=GetID()
s.listed_names={89943723,42015635}  -- Neos, Neo Space

function s.initial_effect(c)
    -- Activate as Field Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Always treated as Neo Space
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetRange(LOCATION_FZONE+LOCATION_GRAVE)
    e1:SetValue(42015635)
    c:RegisterEffect(e1)
    aux.AddCodeList(c,42015635)

    -- End Phase: Prevent Neos Fusions from shuffling
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SKIP_END_PHASE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.skipfilter)
    c:RegisterEffect(e2)

    -- Main Phase: Search 1 Neo-Spacian
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- GY effect: Send Neos or Neo-Spacian to recover this card
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

-- Prevent Neos Fusions from shuffling during End Phase
function s.skipfilter(e,c)
    return c:IsType(TYPE_FUSION) and c:ListsCode(89943723)
end

-- Search Neo-Spacian from Deck (robust)
function s.thfilter(c)
    return (c:IsSetCard(0x1f) or c:IsCode(80896940,43237273,17955766,44762290,65338781,80344569))
        and c:IsAbleToHand()
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

-- GY effect: Only usable if not sent this turn
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetTurnID() < Duel.GetTurnCount()
end
function s.cfilter(c)
    return c:IsCode(89943723) or (c:IsSetCard(0x1f) and c:IsAbleToGraveAsCost

