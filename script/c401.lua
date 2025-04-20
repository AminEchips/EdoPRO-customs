--Starry Knight Tendhel
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand by revealing
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Tribute 1 LIGHT monster to Summon a "Starry Knight" monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}

-- Effect 1: Reveal another Starry Knight or Level 7 LIGHT Dragon to Special Summon this
function s.revealfilter(c)
    return (c:IsSetCard(0x15b) or (c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT)))
        and not c:IsPublic()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,c)
    if #g==0 then return end
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
        and c:IsFaceup() and c:IsLevelBelow(6) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(7)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

-- Effect 2: Tribute 1 LIGHT monster to summon 1 "Starry Knight" monster from hand or GY
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x15b) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.trfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup() and c:IsReleasable()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.trfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.trfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectTarget(tp,s.trfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    Duel.HintSelection(Group.FromCards(tc))
    if Duel.Release(tc,REASON_COST)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
