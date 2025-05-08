--Noble Arms Chalice Holy Grail
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    c:EnableCounterPermit(0x1b)

    --Cannot be destroyed or targeted by effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    --Add counter when different name Noble Knight is Special Summoned from Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_COUNTER)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.ctcon)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)

    --Send to GY with 5 counters to Special Summon 4 monsters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.spcon)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Check unique name Noble Knight from Extra
function s.cfilter(c,tp)
    return c:IsSetCard(0x107a) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:GetSummonLocation()==LOCATION_EXTRA and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsCanAddCounter(0x1b,1) and c:GetCounter(0x1b)<5 then
        c:AddCounter(0x1b,1)
    end
end

-- Condition to activate if 5 counters
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1b)>=5
end
-- Cost: Send this card to GY
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Check if valid monsters exist
function s.spfilter1(c,e,tp)
    return c:IsCode(980973) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Artorigus (example)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0xa8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Laundsallyn
end
function s.spfilter3(c,e,tp)
    return c:IsSetCard(0x107a) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Roland
end
function s.spfilter4(c,e,tp)
    return c:IsCode(39272762) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Emperor Charles (example)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=4
            and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.spfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 then return end
    local g=Group.CreateGroup()
    local sg1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local sg2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local sg3=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local sg4=Duel.SelectMatchingCard(tp,s.spfilter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    g:Merge(sg1)
    g:Merge(sg2)
    g:Merge(sg3)
    g:Merge(sg4)
    if #g==4 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
