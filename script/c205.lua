-- EN - Contact Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Always treated as Neo Space
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
    e0:SetValue(42015635) -- "Neo Space"
    c:RegisterEffect(e0)
    aux.AddCodeList(c,42015635)

    -- Grant effect + shuffle for Neos Fusions
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetOperation(s.grantop)
    c:RegisterEffect(e1)

    -- Search Neo-Spacian
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- GY effect: banish to Special Summon Neo-Spacian
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.spcon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- End Phase: shuffle Neos Fusions
function s.grantfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsFaceup() and c:ListsCode(89943723)
end
function s.grantop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.grantfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- Search Neo-Spacian
function s.thfilter(c)
    return c:IsSetCard(0x1f) and c:IsAbleToHand()
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

-- GY effect: only usable if this card wasn’t sent this turn
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetTurnID() < Duel.GetTurnCount()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
