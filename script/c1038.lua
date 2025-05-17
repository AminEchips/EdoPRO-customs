--Branded in Gold
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_names={68468459} -- Fallen of Albaz
s.listed_series={0x160} -- Branded

function s.thfilter(c)
    return c:IsAbleToHand() and (c:IsCode(68468459) or (c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT)))
end

function s.filter1(c,e)
    return not c:IsImmuneToEffect(e)
end

function s.filter2(c,e,tp,m,f,chkf)
    return c:IsLevelBelow(8) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(m,nil,chkf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Step 1: Search
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)

    local added=g:GetFirst()
    if not added then return end

    -- Step 2: Fusion Summon
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
    if added:IsLocation(LOCATION_HAND) or added:IsLocation(LOCATION_MZONE) then
        mg1:AddCard(added)
    end

    local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    if #sg1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg1:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if tc then
            local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            tc:SetMaterial(mat)
            Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
