--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (continuous spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Send 1 Fusion Monster you control to GY; Special Summon 1 Neo-Spacian from GY with same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Shuffle Fusion Monster mentioning "Elemental HERO Neos" into Extra Deck when sent to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    -- Place 1 "Neo Space" from Deck or GY into Field Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.fztg)
    e3:SetOperation(s.fzop)
    c:RegisterEffect(e3)
end

-- Effect 1 Helpers
function s.filter1(c,tp)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
function s.filter2(c,attr)
    return c:IsSetCard(0x1f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local attr=g:GetFirst():GetAttribute()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,attr):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Effect 2 Helpers
function s.tdfilter(c)
    return c:IsType(TYPE_FUSION) and c:GetText() and c:GetText():lower():find("elemental hero neos")
        and c:IsAbleToExtra()
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tdfilter,1,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.tdfilter,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.tdfilter,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- Effect 3: Neo Space placement
function s.nsfilter(c,tp)
    return c:IsCode(42015635) and not c:IsForbidden()
        and (Duel.GetLocationCount(tp,LOCATION_FZONE)>0 or c:IsLocation(LOCATION_FZONE))
end
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end
