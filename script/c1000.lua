--Despian Redemption
local s,id=GetID()
function s.initial_effect(c)
    -- Archetype and name reference
    s.listed_series={0x166} -- Despia
    s.listed_names={68468459} -- Fallen of Albaz

    -- Send self + 1 Despia to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sdtg)
    e1:SetOperation(s.sdop)
    c:RegisterEffect(e1)

    -- Fusion Summon (Quick Effect)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)
end

-- Send from hand + send Despia from Deck or Extra Deck
function s.despiafilter(c)
    return c:IsSetCard(0x166) and c:IsAbleToGrave()
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.despiafilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
            and e:GetHandler():IsAbleToGrave()
    end
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.despiafilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end

-- Fusion Summon effect
function s.fusfilter(c,e,tp,m,f,chkf)
    return c:IsLevelAbove(8) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local m=Duel.GetFusionMaterial(tp)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,m,nil,chkf)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local m1=Duel.GetFusionMaterial(tp)
    local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,m1,nil,chkf)
    if #sg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=sg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    local mat=Duel.SelectFusionMaterial(tp,tc,m1,nil,chkf)
    tc:SetMaterial(mat)
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    tc:CompleteProcedure()
end
