--Odd-Eyes Jade Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,4,2)
    c:EnableReviveLimit()

    --Quick Xyz Summon into Odd-Eyes Lapis Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCondition(s.xyzcon)
    e1:SetTarget(s.xyztg)
    e1:SetOperation(s.xyzop)
    c:RegisterEffect(e1)

    --Special Summon 1 banished non-Xyz Dragon if this is banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_names={141} -- Odd-Eyes Lapis Dragon
s.listed_series={0x99}

--e1: Quick Xyz Summon during opponent's turn into Lapis
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()~=tp
        and c:IsType(TYPE_XYZ)
        and c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x99)
end
function s.xyzfilter(c,mc,e,tp)
    return c:IsCode(141) and mc:IsCanBeXyzMaterial(c)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler(),e,tp) end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,c,e,tp)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        if sc then
            local mg=c:GetOverlayGroup()
            if #mg>0 then
                Duel.Overlay(sc,mg)
            end
            sc:SetMaterial(Group.FromCards(c))
            Duel.Overlay(sc,Group.FromCards(c))
            Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
            sc:CompleteProcedure()
        end
    end
end

--e2: When banished, revive 1 banished non-Xyz Dragon
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_XYZ)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
