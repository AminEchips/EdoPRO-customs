--Darklord Na'amah
local s,id=GetID()
function s.initial_effect(c)
    -- Can only be Special Summoned once per turn
    c:SetSPSummonOnce(id)

    -- If added to hand, even by drawing: you can Special Summon it and place a "Darklord" from GY or banished on top/bottom of Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- If sent to GY as Fusion material: add 1 "Darklord" from Deck to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={0xef}

-- Effect 1: If added to hand (not by draw)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsReason(REASON_DRAW)
end

function s.spfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToDeck()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsRelateToEffect(e)
        and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- "Choose a Darklord to place"
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3)) -- "Top or bottom of Deck"
            local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- 0 = top, 1 = bottom
            Duel.SendtoDeck(g:GetFirst(),nil,opt==1 and 1 or 0,REASON_EFFECT)
        end
    end
end

-- Effect 2: If sent to GY as Fusion Material
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_MATERIAL+REASON_FUSION)
end

function s.thfilter(c)
    return c:IsSetCard(0xef) and not c:IsCode(id) and c:IsAbleToHand()
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
