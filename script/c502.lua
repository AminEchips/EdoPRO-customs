--Altergeist Abyzec
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and Special Summon this card as a monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Triggered effect if Summoned to a zone an "Altergeist" Link Monster points to
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series={0x103}

-- Special Summon this card as a monster
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x103,
            TYPE_EFFECT+TYPE_MONSTER+TYPE_TUNER,0,1000,2,RACE_SPELLCASTER,ATTRIBUTE_WATER) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x103,
        TYPE_EFFECT+TYPE_MONSTER+TYPE_TUNER,0,1000,2,RACE_SPELLCASTER,ATTRIBUTE_WATER) then
        c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TUNER, ATTRIBUTE_WATER, RACE_SPELLCASTER, 2, 1000, 0)
        Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
    end
end

-- Check if summoned to a zone pointed to by an "Altergeist" Link Monster
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local seq=c:GetSequence()
    local zone=0
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x103)
    for tc in aux.Next(g) do
        if tc:IsType(TYPE_LINK) then
            zone = zone | tc:GetLinkedZone()
        end
    end
    return bit.extract(zone,seq)~=0
end

-- Send S/T to GY and Special Summon Altergeist Link from GY
function s.filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x103) and c:IsType(TYPE_LINK)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not Duel.IsExistingMatchingCard(s.samecodefilter,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
function s.samecodefilter(c,code)
    return c:IsCode(code)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if sc then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
end




