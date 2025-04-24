--Altergeist Formatting
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --Synchro Summon during opponent's turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
    e1:SetTarget(s.syntg)
    e1:SetOperation(s.synop)
    c:RegisterEffect(e1)

    --Ritual Summon during either Main Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(TIMING_MAIN_END,TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.rittg)
    e2:SetOperation(s.ritop)
    c:RegisterEffect(e2)
end

-- Synchro Summon logic
-- Valid Synchro Monster Filter
function s.synfilter(c)
    return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER)
        and Duel.IsExistingMatchingCard(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,0,1,nil,c)
        and Duel.IsPlayerCanSpecialSummon(tp)
end

-- Synchro Summon Target
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Synchro Summon Operation
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    local sc=g:GetFirst()
    if not sc then return end
    Duel.SynchroSummon(tp,sc,nil)
    if sc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        sc:RegisterEffect(e1)
    end
end

-- Ritual Summon logic
function s.ritfilter(c)
    return c:IsSetCard(0x103) and c:IsRitualMonster()
end
function s.matfilter(c)
    return c:IsAbleToGrave() and (c:IsLevelAbove(1) or c:IsType(TYPE_LINK))
end
function s.getLevelOrLink(c)
    return c:IsType(TYPE_LINK) and c:GetLink() or c:GetLevel()
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
    local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if not rc then return end
    local lv=rc:GetLevel()
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    aux.GCheckAdditional=function(g)
        local sum=0
        for tc in aux.Next(g) do
            sum=sum+s.getLevelOrLink(tc)
        end
        return sum>=lv
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local mat=mg:SelectSubGroup(tp,aux.TRUE,false,1,99)
    aux.GCheckAdditional=nil
    if not mat then return end
    rc:SetMaterial(mat)
    Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end
