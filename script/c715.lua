--Noble Arms - Chalice Holy Grail
local s,id=GetID()
local COUNTER_HOLY = 0x1b

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_HOLY)
    c:SetCounterLimit(COUNTER_HOLY,5)

    -- Activate as Continuous Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Gain counters when Noble Knight summoned from Extra
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.ctcon)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)

    -- Special Summon 4 monsters from 4 different locations, each different archetype
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Counter condition
function s.ctfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x107a)
        and c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:GetSummonLocation()==LOCATION_EXTRA
        and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.ctfilter,1,nil,tp)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local ct=eg:FilterCount(s.ctfilter,nil,tp)
    if ct>0 then
        e:GetHandler():AddCounter(COUNTER_HOLY,ct)
    end
end

-- Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(COUNTER_HOLY)==5
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Unified summon filter
function s.validTarget(c,e,tp)
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
    if not (c:IsSetCard(0xa7) or c:IsSetCard(0xa8) or c:IsSetCard(0x149) or c:IsCode(77656797)) then return false end
    return true
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.validTarget,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=4 and s.checkValidGroups(g)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end

-- Check that we can choose 4 cards of different archetypes AND locations
function s.checkValidGroups(g)
    return g:CheckSubGroup(s.groupValid,4,4)
end

function s.groupValid(g)
    local archetypes={}
    local zones={}
    for tc in g:Iter() do
        local zone = tc:IsLocation(LOCATION_EXTRA) and LOCATION_EXTRA or tc:GetLocation()
        local arch = s.getArchetype(tc)
        if not arch or zones[zone] or archetypes[arch] then return false end
        zones[zone] = true
        archetypes[arch] = true
    end
    return true
end

function s.getArchetype(c)
    if c:IsSetCard(0xa7) then return 0xa7
    elseif c:IsSetCard(0xa8) then return 0xa8
    elseif c:IsSetCard(0x149) then return 0x149
    elseif c:IsCode(77656797) then return 77656797
    else return nil end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.validTarget,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:SelectSubGroup(tp,s.groupValid,false,4,4)
    if sg then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
