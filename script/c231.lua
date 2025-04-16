--Elemental HERO Super Neos
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Materials
    Fusion.AddProcMix(c,true,true,89943723,s.ffilter) -- "Elemental HERO Neos" + 1 "HERO" Fusion Monster

    -- Gains ATK for each "Neo-Spacian" in GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- GY to field summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Float into Level 7 Fusion
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.fltcon)
    e3:SetTarget(s.flttg)
    e3:SetOperation(s.fltop)
    c:RegisterEffect(e3)
end

-- Fusion filter
function s.ffilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and not c:IsCode(89943723)
end

-- ATK gain
function s.atkfilter(c)
    return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*400
end

-- Send 1 to GY to Special Summon 1 "Neo-Spacian" from Deck
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
    end
end

-- Float into Level 7 Fusion Monster that mentions Neo-Spacian
function s.fltcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.fltfilter(c,e,tp)
    return c:IsLevel(7) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true)
        and c:GetText():find("Neo%-Spacian")
end
function s.flttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
        and Duel.IsExistingMatchingCard(s.fltfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fltop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.fltfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,true,POS_FACEUP)
        g:GetFirst():CompleteProcedure()
    end
end
