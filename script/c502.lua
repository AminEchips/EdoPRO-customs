--Altergeist Abyzec
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon this card as monster if Altergeist is Special Summoned from Extra Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- If summoned to zone an Altergeist Link points to, send 1 S/T, then revive Link
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.linkcon)
    e2:SetTarget(s.linktg)
    e2:SetOperation(s.linkop)
    c:RegisterEffect(e2)
end
s.listed_series={0x103}

-- e1
function s.cfilter(c,tp)
    return c:IsSetCard(0x103) and c:IsSummonPlayer(tp) and c:IsType(TYPE_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x103,TYPES_EFFECT+TYPE_TUNER,0,1000,2,RACE_SPELLCASTER,ATTRIBUTE_WATER)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x103,TYPES_EFFECT+TYPE_TUNER,0,1000,2,RACE_SPELLCASTER,ATTRIBUTE_WATER) then
        c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TUNER)
        Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
    end
end

-- e2
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetColumnGroup()
    for sc in aux.Next(zone) do
        if sc:IsType(TYPE_LINK) and sc:IsSetCard(0x103) and sc:GetLinkedGroup():IsContains(c) then
            return true
        end
    end
    return false
end
function s.linkfilter(c,tp)
    return c:IsSetCard(0x103) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
        and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_SZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_SZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_SZONE,0,1,1,nil)
    if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if sc then Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end
end
