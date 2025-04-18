--Elemental HERO Terra Hurricane
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.fusionfilter,2)
    -- Gains EARTH Attribute while on field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(ATTRIBUTE_EARTH)
    c:RegisterEffect(e0)

    -- Destroy 1 Spell/Trap
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Tribute and search
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Special Summon on battle destroy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.material_setcode={0x3008}

function s.fusionfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x3008,fc,sumtype,tp) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
        and (c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_WIND,fc,sumtype,tp))
end

-- Destroy S/T
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end

-- Tribute to search
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsReleasable,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,Card.IsReleasable,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
    return c:IsSetCard(0x3008) and not c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WIND) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Special Summon from hand and GY
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    g1:Merge(g2)
    if #g1>0 then Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP) end
end
