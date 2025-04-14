--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    --Setcode for synergy with "Neo Space"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x1f) -- SET_NEO_SPACIAN
    c:RegisterEffect(e0)

    --Send 1 Fusion Monster you control to GY, summon 1 Neo-Spacian with same attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --If a "Elemental HERO Neos"-mentioning Fusion is sent to GY, shuffle it and draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.shcon)
    e2:SetTarget(s.shtg)
    e2:SetOperation(s.shop)
    c:RegisterEffect(e2)

    --Place "Neo Space" from Deck or GY during End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.fztg)
    e3:SetOperation(s.fzop)
    c:RegisterEffect(e3)
end

--Effect 1: Send Fusion + Summon Neo-Spacian
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.nfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute(),e,tp)
end
function s.nfilter(c,attr,e,tp)
    return c:IsSetCard(0x1f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
    if tg and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.nfilter,tp,LOCATION_GRAVE,0,1,1,nil,tg:GetAttribute(),e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

--Effect 2: Shuffle HERO Fusion with "Elemental HERO Neos" in text
function s.filtertext(c)
    local text = aux.GetOriginalCardText(c)
    return text and text:find("Elemental HERO Neos") and c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filtertext,1,nil)
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.filtertext,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.filtertext,nil)
    if #g==0 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--Effect 3: Place Neo Space in Field Zone
function s.fzfilter(c)
    return c:IsCode(42015635) and not c:IsForbidden()
end
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_FZONE)>0
        and Duel.IsExistingMatchingCard(s.fzfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.fzfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end

s.listed_series={0x1f}
s.listed_names={42015635} -- Neo Space
