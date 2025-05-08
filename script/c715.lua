--Noble Arms - Chalice Holy Grail
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Continuous Spell)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Add 1 counter when different Noble Knight is Special Summoned from Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)

    -- Special Summon from 4 different zones with different archetypes
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    c:EnableCounterPermit(0x1b)
end

-- Effect 2: Add 1 counter
function s.ctfilter(c,tp,existing)
    return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:GetSummonLocation()==LOCATION_EXTRA and not existing[c:GetCode()]
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsCanAddCounter(0x1b,1) then return end

    -- Track name uniqueness during chain
    local existing={}
    for tc in eg:Iter() do
        if s.ctfilter(tc,tp,existing) then
            c:AddCounter(0x1b,1)
            existing[tc:GetCode()]=true
        end
    end
end

-- Condition to activate 3rd effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1b)>=5
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Filters for the four archetypes and zones
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
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
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
