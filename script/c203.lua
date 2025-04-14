--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Send 1 Fusion Monster you control to GY, SS 1 Neo-Spacian with same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- If Fusion Monster that mentions "Elemental HERO Neos" is sent to GY, shuffle it into the Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    -- During End Phase: place 1 "Neo Space" from Deck or GY into Field Zone
    local e3=Effect.CreateEffect(c)
   e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.fzcon)
    e3:SetTarget(s.fztg)
    e3:SetOperation(s.fzop)
    c:RegisterEffect(e3)
end

-- Effect 1: Send Fusion, Summon Neo-Spacian
function s.filter1(c,tp)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute(),tp)
end
function s.filter2(c,attr,tp)
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
        local sc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,attr,tp):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Effect 2: Shuffle Fusion back to Extra if it mentions "Elemental HERO Neos"
function s.tdfilter(c)
    local text = c:GetText()
    return c:IsType(TYPE_FUSION) and text and text:lower():find("elemental hero neos") and c:IsAbleToExtra()
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

-- Effect 3: Place "Neo Space" in Field Zone
function s.fzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.nsfilter(c)
    return c:IsCode(42015635) and not c:IsForbidden()
end
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_FZONE)>0
        and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end
