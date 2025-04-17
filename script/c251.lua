--Evil Domination
local s,id=GetID()
function s.initial_effect(c)
    -- Activation
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_names={247,248,249,250,94820406}
s.listed_series={0x6008}
s.dark_calling=true

function s.filter(cid)
    return function(c)
        return c:IsCode(cid) and c:IsAbleToRemoveAsCost()
    end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter(247),tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter(248),tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter(249),tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.filter(250),tp,LOCATION_GRAVE,0,1,nil)
    end
    local g1=Duel.SelectMatchingCard(tp,s.filter(247),tp,LOCATION_GRAVE,0,1,1,nil)
    local g2=Duel.SelectMatchingCard(tp,s.filter(248),tp,LOCATION_GRAVE,0,1,1,nil)
    local g3=Duel.SelectMatchingCard(tp,s.filter(249),tp,LOCATION_GRAVE,0,1,1,nil)
    local g4=Duel.SelectMatchingCard(tp,s.filter(250),tp,LOCATION_GRAVE,0,1,1,nil)
    local g=g1+g2+g3+g4
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x6008) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetChainLimitTillChainEnd(aux.FALSE) -- Prevent responses
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end
