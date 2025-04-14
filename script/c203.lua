--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Send 1 Fusion monster, then SS Neo-Spacian with same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)

    -- Shuffle Fusion Monsters that mention "Elemental HERO Neos" into Extra Deck
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

    -- Place "Neo Space" from Deck or GY during End Phase (Necroworld Banshee style)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.fztg)
    e3:SetOperation(s.fzop)
    c:RegisterEffect(e3)
end

-- Send Fusion, then SS Neo-Spacian with same Attribute
function s.filter1(c,tp)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
function s.filter2(c,attr)
    return c:IsSetCard(0x1f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local attr=g:GetFirst():GetAttribute()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,attr)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Shuffle "Elemental HERO Neos"-mentioning Fusion to ED
function s.tdfilter(c)
    return c:IsType(TYPE_FUSION) and c:GetText():lower():find("Elemental HERO Neos") and c:IsAbleToExtra()
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

-- Place "Neo Space" (card ID: 42015635) from Deck or GY into Field Zone
s.listed_names={42015635}
function s.nsfilter(c,tp)
    return c:IsCode(42015635) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if tc then
        Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
    end
end
