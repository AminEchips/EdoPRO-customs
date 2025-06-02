--Raidraptor's Rank-Up-Magic - Rising Phoenix Force
local s,id=GetID()
function s.initial_effect(c)
    -- Activation and main effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filter: DARK Xyz on field or in GY
function s.xyzfilter(c,e,tp)
    local rk=c:GetRank()
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
        and c:IsCanBeEffectTarget(e)
        and Duel.IsExistingMatchingCard(s.rrfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk)
end

-- Filter: 3 Ranks higher "Raidraptor" Xyz
function s.rrfilter(c,e,tp,tc,rk)
    return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
        and c:GetRank()==rk+3
        and tc:IsCanBeXyzMaterial(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.xyzfilter(chkc,e,tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
    if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local rk=tc:GetRank()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rrfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,rk)
    local sc=g:GetFirst()
    if sc then
        local mat=tc:GetOverlayGroup()
        sc:SetMaterial(Group.FromCards(tc))
        Duel.Overlay(sc,mat)

        -- Prevent this Spell from being sent to GY on attach
        c:CancelToGrave()

        -- Attach target and this Spell
        Duel.Overlay(sc,Group.FromCards(tc,c))

        if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            sc:CompleteProcedure()
        end
    end

    -- Optional destroy if activated during Battle Phase
    if Duel.IsBattlePhase() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end
