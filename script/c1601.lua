--Valdis of the Nordic Ascendant
local s,id=GetID()
function s.initial_effect(c)
    -- Quick Effect: Reveal to protect Aesir GY effects this turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.revealcon)
    e1:SetCost(s.revealcost)
    e1:SetOperation(s.revealop)
    c:RegisterEffect(e1)

    -- Send 1 "Nordic" from hand to GY; SS this + 1 Level 2 "Nordic Ascendant" from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Effect 1: Reveal for GY protection
function s.revealcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.revealcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    -- Reveal self
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.revealop(e,tp,eg,ep,ev,re,r,rp)
    -- Opponent cannot respond to Aesir effects activated in GY this turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
    local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
    local rc=re:GetHandler()
    return rc:IsSetCard(0x4b) and loc==LOCATION_GRAVE
end

-- Effect 2: Send 1 Nordic from hand to GY; SS this + 1 Level 2 Nordic Ascendant from Deck
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end
function s.costfilter(c)
    return c:IsSetCard(0x42) and c:IsAbleToGraveAsCost()
end
function s.spfilter(c,e,tp)
    return c:IsLevel(2) and c:IsSetCard(0x3042) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
        end
        Duel.SpecialSummonComplete()
    end
end
