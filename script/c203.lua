-- EN - Evolution Neo Space
local s,id=GetID()

function s.initial_effect(c)
    -- Activate (Continuous Spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Effect 1: Send Fusion → Special Summon Neo-Spacian with same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- Effect 2: Shuffle Fusions that list Neos into Extra Deck
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

    -- Effect 3: During End Phase, place Neo Space into Field Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.fzcond)
    e3:SetOperation(s.fzop)
    c:RegisterEffect(e3)
end

-- Effect 1
function s.fusionfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGrave() and c:IsFaceup()
        and Duel.IsExistingMatchingCard(s.neofilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetAttribute())
end
function s.neofilter(c,e,tp,attr)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(attr)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        local g=Duel.SelectMatchingCard(tp,s.neofilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetAttribute())
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Effect 2
function s.neosfusionfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_GRAVE)
        and c:IsAbleToExtra() and c.material and c:CheckFusionMaterial(aux.FilterBoolFunction(Card.IsCode,89943723))
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.neosfusionfilter,1,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=eg:Clone()
    g:KeepAlive()
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    local tg=g:Filter(s.neosfusionfilter,nil)
    if #tg>0 then
        Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- Effect 3
function s.fzcond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_FZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,42015635)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end

