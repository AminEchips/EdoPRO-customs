--Salamangreat Violet Serpent
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)

    -- Fusion Materials: 2 "Salamangreat" + 1 Fusion or Link Monster
    Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        aux.FilterBoolFunction(Card.IsSetCard,0x119),
        s.fmlinkfilter)

    -- Proper Fusion Summon: 1 FIRE Fusion Monster using field/GY (banished)
    local params = {
        fusfilter = s.fusfilter,
        matfilter = s.matfilter,
        extrafil = s.extrafilter,
        extraop = Fusion.BanishMaterial,
        stage2 = nil
    }
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
    e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Reincarnation Summon effect
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

-- Material filter: must be a Fusion or Link
function s.fmlinkfilter(c)
    return c:IsType(TYPE_FUSION+TYPE_LINK)
end

-- Fusion filter: must be a FIRE Fusion Monster
function s.fusfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Allow materials from field or GY
function s.matfilter(c)
    return c:IsAbleToRemove() and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end

-- Provide custom material pool
function s.extrafilter(e,tp,mg)
    return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil), aux.FALSE
end

-- Reincarnation condition
function s.reinccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsReincarnationSummoned()
end

-- Reincarnation: SS 1 banished + add 1 Salamangreat S/T
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
