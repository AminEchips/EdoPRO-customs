--Darklord Ismael, the Rejected
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY))

    -- Indestructible by battle or by banishing from GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e2)

    -- Banish a Darklord in GY to recover a different one
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)

    -- If this Fusion Summoned card leaves field by opponent's effect: Add/Special a Level 5-7 Darklord
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg2)
    e4:SetOperation(s.spop2)
    e4:SetCountLimit(1,{id,1})
    c:RegisterEffect(e4)
end
s.listed_series={0xef}

function s.matfilter(c)
    return c:IsSetCard(0xef) and c:IsLevelAbove(6)
end

-- Banish 1 "Darklord" in GY to recover another
function s.rmfilter1(c)
    return c:IsSetCard(0xef) and c:IsAbleToRemove()
end
function s.rmfilter2(c,code)
    return c:IsSetCard(0xef) and not c:IsCode(code) and c:IsAbleToHand()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter1,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp,s.rmfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
    if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
        local code=rg:GetFirst():GetCode()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_GRAVE,0,1,1,nil,code)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- If Fusion Summoned card leaves field by opponent
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0xef) and c:IsLevelBetween(5,7)
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- Choose: Add or Special
    local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- 0 = Add, 1 = SS
    if op==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif tc:IsAbleToHand() then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
