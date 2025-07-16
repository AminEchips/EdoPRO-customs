--Halja of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)
    -- Normal Summon: revive 1 Level 5 or lower Nordic
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- Once per turn: banish 1 monster from hand or GY → change Level to that monster's
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- If banished: send 1 Nordic or Aesir from Extra Deck to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_REMOVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end

-- e1: Special Summon 1 Level 5 or lower Nordic from GY
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x42) and c:IsLevelBelow(5)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- e2: Banish 1 monster from hand or GY; copy its Level
function s.lvfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        local rc=g:GetFirst()
        if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=0 and rc:IsMonster() and rc:GetLevel()>0 then
            local lvl=rc:GetLevel()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(lvl)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end

-- e3: If banished, send 1 Nordic or Aesir from Extra Deck to GY
function s.tgfilter(c)
    return (c:IsSetCard(0x42) or c:IsSetCard(0x4b)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
