--Bystial Alba-Lubellion
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion materials: "Fallen of Albaz" + 2 Level 6 "Bystial" monsters
    local albaz=aux.FilterBoolFunction(Card.IsCode,68468459)
    local bystial=aux.FilterBoolFunction(function(c) return c:IsSetCard(0x189) and c:IsLevel(6) end)
    Fusion.AddProcMixRep(c,true,true,albaz,bystial,2,99)

    -- Tribute 1 other Level 8 Fusion to destroy opponent's monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Special Summon a banished "Bystial", then optionally Synchro Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- If opponent makes this leave the field, shuffle all banished LIGHT/DARK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.tdcon)
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
end

s.listed_names={68468459}
s.material_setcode={0x189}

-- Destroy opponent monsters by tributing a Level 8 Fusion
function s.cfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsLevel(8) and c:IsReleasable()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil) end
    local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
    e:SetLabel(g:GetFirst():GetMaterialCount())
    Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,ct,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Special Summon banished "Bystial" monster and Synchro optionally
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsSetCard,1,nil,0x189)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        local sg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_MONSTER),tp,LOCATION_MZONE,0,nil)
        if sg:GetClassCount(Card.GetLevel)>=2 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_SYNCHRO)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
            Duel.SynchroSummon(tp,nil,nil)
        end
    end
end

-- Shuffle all banished LIGHT/DARK monsters if opponent removes this
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return rp~=tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(c) return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck() end,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToDeck() end,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
