--Raidraptor - Force Lanius
local s,id=GetID()
function s.initial_effect(c)
    -- Track if added to hand this turn (excluding draw)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_TO_HAND)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)

    -- Effect 1: End Phase Special Summon if added to hand this turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Effect 2: Register End Phase search if destroyed this turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetOperation(s.regop2)
    c:RegisterEffect(e2)
end
s.listed_series={0xba} -- Raidraptor
s.listed_names={id}

-- Track if added to hand this turn (but not drawn)
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsReason(REASON_DRAW) then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

-- Effect 1: End Phase Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.tgfilter(c)
    return c:IsSetCard(0xba) and c:IsLevel(4) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Effect 2: Register End Phase search if destroyed this turn
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetRange(LOCATION_GRAVE)
        e1:SetCountLimit(1,{id,1})
        e1:SetTarget(s.thtg)
        e1:SetOperation(s.thop)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        c:RegisterEffect(e1)
    end
end
function s.thfilter(c)
    return c:IsCode(id) and c:IsAbleToHand()
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
