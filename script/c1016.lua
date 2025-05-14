--Bystial Alba-Lubellion
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Materials: 2 Level 6 "Bystial" monsters + "Fallen of Albaz"
    Fusion.AddProcMixRep(c, true, true,
        function(c) return c:IsLevel(6) and c:IsSetCard(0x189) end, 2, 2, 68468459)

    -- Tribute 1 other Level 8 Fusion to destroy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Special Summon 1 banished "Bystial", then Synchro
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- On leave field by opponent: shuffle all LIGHT and DARK banished into Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(function(e) return e:GetHandler():IsPreviousControler(e:GetHandlerPlayer()) and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE) and e:GetHandler():GetReasonPlayer()~=e:GetHandlerPlayer() end)
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
end

-- Cost for destroy effect
function s.cfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsLevel(8) and c:IsReleasable()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil) end
    local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
    Duel.Release(g,REASON_COST)
    e:SetLabel(g:GetFirst():GetMaterialCount())
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,ct,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Special Summon and Synchro
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        Duel.SpecialSummonComplete()
        Duel.BreakEffect()
        if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_SYNCHRO) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
            Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_SYNCHRO)
            Duel.SynchroSummon(tp,Duel.GetFirstMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_SYNCHRO),nil)
        end
    end
end

-- Shuffle LIGHT and DARK monsters
function s.tdfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
