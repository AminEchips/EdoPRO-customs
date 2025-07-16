--Fafnir of the Nordic Beasts
local s,id=GetID()
function s.initial_effect(c)
    -- e1/e2: Special Summon from hand when a Nordic or Aesir monster is sent to your GY or destroyed
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e2)

    -- e3/e4: Search a Nordic monster (on Normal or Special Summon)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

-- Special Summon condition: if any other "Nordic" or "Aesir" monster was sent to your GY
function s.cfilter(c,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsPreviousControler(tp)
        and (c:IsSetCard(0x42) or c:IsSetCard(0x4b))
        and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Search effect: add a "Nordic" monster from Deck to hand
function s.thfilter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id) and c:IsAbleToHand()
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
