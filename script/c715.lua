--Noble Arms - Chalice Holy Grail
local s,id=GetID()
local COUNTER_HOLY = 0x1b

function s.initial_effect(c)
    -- Enable counters
    c:EnableCounterPermit(COUNTER_HOLY)
    c:SetCounterLimit(COUNTER_HOLY,5)

    -- Activate as Continuous Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Add counter when Noble Knight is Special Summoned from Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.ctcon)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)

    -- Special Summon 4 monsters from different locations
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Counter gain condition
function s.ctfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:GetSummonLocation()==LOCATION_EXTRA and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.ctfilter,1,nil,tp)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=eg:FilterCount(s.ctfilter,nil,tp)
    if ct>0 and c:IsRelateToEffect(e) then
        c:AddCounter(COUNTER_HOLY,ct)
    end
end

-- Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(COUNTER_HOLY)==5
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Filters for 4 archetypes and 4 locations
function s.handfilter(c,e,tp)
    return c:IsSetCard(0xa7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.deckfilter(c,e,tp)
    return c:IsSetCard(0xa8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gravefilter(c,e,tp)
    return c:IsSetCard(0x149) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.extraFilter(c,e,tp)
    return c:IsCode(77656797) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=4
            and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.extraFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 then return end
    local g1=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local g2=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local g3=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local g4=Duel.SelectMatchingCard(tp,s.extraFilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local g=g1+g2+g3+g4
    if #g==4 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
