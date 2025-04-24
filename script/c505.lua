--Altergeist Formatting
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --Synchro Summon (Opponent's Turn)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
    e1:SetTarget(s.sytg)
    e1:SetOperation(s.syop)
    c:RegisterEffect(e1)

    --Ritual Summon (Main Phase of either player)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.ritg)
    e2:SetOperation(s.riop)
    c:RegisterEffect(e2)
end

--Synchro
function s.synfilter(c,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER)
        and Duel.IsPlayerCanSpecialSummon(tp)
        and Duel.CheckSynchroMaterial(c,nil,nil,tp)
end
function s.sytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc then
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
end

--Ritual
function s.ritfilter(c)
    return c:IsSetCard(0x103) and c:IsRitualMonster()
end
function s.matfilter(c)
    return c:IsAbleToRelease() and (c:IsType(TYPE_LINK) or c:IsLevelAbove(1))
end
function s.checklevel(g,rc)
    local lv=rc:GetLevel()
    local sum=0
    for tc in aux.Next(g) do
        sum = sum + (tc:IsType(TYPE_LINK) and tc:GetLink() or tc:GetLevel())
    end
    return sum>=lv
end
function s.ritg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
           and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.riop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if not rc then return end
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    local g=aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.checklevel,false,rc)
    if not g then return end
    rc:SetMaterial(g)
    Duel.Release(g,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end
