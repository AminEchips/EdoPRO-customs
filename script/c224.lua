--Elemental HERO Crazy Diamond
local s,id=GetID()
function s.initial_effect(c)
    --Must be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x3008),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))

    --Piercing for all Warrior monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(e,c) return c:IsRace(RACE_WARRIOR) end)
    c:RegisterEffect(e1)

    --Revive monster with declared Attribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Summon Great Tornado on leaving field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
    e3:SetTarget(s.gttg)
    e3:SetOperation(s.gtop)
    c:RegisterEffect(e3)
end

s.material_setcode={0x3008}

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(Card.IsReason,nil,REASON_BATTLE)
    if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
    local g=eg:Filter(Card.IsReason,nil,REASON_BATTLE):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE_EFFECT)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
    end
end

function s.gttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gtfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.gtfilter(c,e,tp)
    return c:IsCode(03642509) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,true)
end

function s.gtop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.gtfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,SUMMON_TYPE_SPECIAL,tp,tp,true,true,POS_FACEUP)
    end
end
