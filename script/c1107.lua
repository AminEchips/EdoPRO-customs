--Salamangreat Violet Serpent
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)

    -- Fusion materials: 2 Salamangreat + 1 Fusion/Link
    Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        s.fmlinkfilter)

    -- On Fusion Summon: Proper Fusion Summon 1 FIRE Fusion from field/GY (banished)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.fuscon)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Reincarnation effect: SS banished + add S/T
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.reinccon)
    e2:SetTarget(s.reinctg)
    e2:SetOperation(s.reincop)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)
end
s.listed_series={0x119}

-- Fusion material filter: must be Fusion or Link
function s.fmlinkfilter(c)
    return c:IsType(TYPE_FUSION+TYPE_LINK)
end

-- Condition: only if this was Fusion Summoned
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Fusion Summon setup using FIRE + field/GY banish
function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and Duel.CheckFusionMaterial(tp,c,nil,nil,s.fusmatfilter,chkf)
end

function s.fusmatfilter(c)
    return c:IsAbleToRemoveAsCost() and (c:IsOnField() or c:IsLocation(LOCATION_GRAVE))
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            and #g>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
    local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)

    local tg=Duel.SelectFusionMaterial(tp,nil,mg,nil,chkf)
    if #tg==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=sg:Select(tp,1,1,nil):GetFirst()
    if not sc then return end

    local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,chkf)
    if #mat==0 then return end

    Duel.Remove(mat,POS_FACEUP,REASON_COST+REASON_MATERIAL)
    Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
end

-- Reincarnation Summon check
function s.reinccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsReincarnationSummoned()
end

function s.reincfilter(c,e,tp)
    return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.stfilter(c)
    return c:IsSetCard(0x119) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.reinctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.reincfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.reincop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp,s.reincfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g2=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g2>0 then
            Duel.SendtoHand(g2,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g2)
        end
    end
end
