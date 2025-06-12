--Salamangreat Violet Serpent
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)

    -- Fusion materials: 2 "Salamangreat" monsters + 1 Fusion or Link monster
    Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        s.fmlinkfilter)

    -- On Fusion Summon: Fusion Summon 1 FIRE Fusion Monster using field/GY (banished)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY) -- important so it triggers even after chains
    e1:SetCondition(s.fuscon)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Reincarnation effect: Special Summon 1 banished Salamangreat + add 1 Salamangreat S/T
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.reinccon)
    e2:SetTarget(s.reinctg)
    e2:SetOperation(s.reincop)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)
end
s.listed_series={0x119}

-- Fusion/Link filter for material
function s.fmlinkfilter(c)
    return c:IsType(TYPE_FUSION+TYPE_LINK)
end

-- e1 condition: only trigger if this card was Fusion Summoned
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- e1: Fusion Summon 1 FIRE Fusion Monster using field/GY (banished)
function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.matfilter(c)
    return c:IsAbleToRemove() and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            and #mg>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)

    -- Pick FIRE Fusion Monster from Extra Deck
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=sg:Select(tp,1,1,nil):GetFirst()
    if not sc then return end

    -- Check available materials
    local matg=mg:Filter(Card.IsCanBeFusionMaterial,sc)
    if #matg<sc.material_count then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local mat=matg:Select(tp,sc.material_count,sc.material_count,nil)
    if #mat>0 then
        sc:SetMaterial(mat)
        Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end

-- e2: Reincarnation trigger condition
function s.reinccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsReincarnationSummoned()
end

-- e2: Reincarnation target and operation
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
