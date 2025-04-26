--Assault Blackwing - Updraft the Swift
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33} -- Blackwing archetype
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Become Tuner if Synchro Summoned using a Blackwing
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.tncon)
    e1:SetValue(TYPE_TUNER)
    c:RegisterEffect(e1)
    -- Add 1 Level 2 or lower Winged Beast during Main Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

----------------------------------------------------------
-- Become Tuner condition
----------------------------------------------------------
function s.tncon(e)
    local c=e:GetHandler()
    local sumtype=c:GetSummonType()
    return sumtype==SUMMON_TYPE_SYNCHRO and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x33)
end

----------------------------------------------------------
-- Search Level 2 or lower Winged Beast
----------------------------------------------------------
function s.thfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsLevelBelow(2) and c:IsAbleToHand()
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
