--The Phantom Knights of Misty Lancing
local s,id=GetID()
function s.initial_effect(c)
    -- Destroy + banish if you control a PK Xyz
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- GY Effect: Revive banished PK Trap as Normal Monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.spcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Check if you control a PK Xyz
function s.pkxyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x10db) and c:IsType(TYPE_XYZ)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.pkxyzfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Destroy + banish
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
    if tc and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
        Duel.BreakEffect()
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

-- Trigger if any PK monster is banished
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsSetCard(0x10db) and c:IsMonster() end,1,nil)
end

-- GY effect target (no targeting)
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end

-- Trap filter to revive
function s.trapfilter(c,e,tp)
    return c:IsSetCard(0xdb) and c:IsType(TYPE_TRAP) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    -- Get the first PK monster banished
    local rc=eg:Filter(function(c) return c:IsSetCard(0x10db) and c:IsMonster() end,nil):GetFirst()
    if not rc then return end

    local lvl=rc:GetLevel()
    if lvl==0 then lvl=rc:GetRank() end
    if lvl==0 then lvl=1 end

    -- Select trap at resolution
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.IsPlayerCanSpecialSummonMonster(tp,tc:GetCode(),0,TYPE_NORMAL+TYPE_MONSTER,1800,0,lvl,RACE_WARRIOR,ATTRIBUTE_DARK) then
        tc:AddMonsterAttribute(TYPE_NORMAL+TYPE_MONSTER)
        Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lvl)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        Duel.SpecialSummonComplete()
    end
end
