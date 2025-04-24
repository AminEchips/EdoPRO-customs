--Altergeist Formatting
local s,id=GetID()
function s.initial_effect(c)
    -- Activate this card
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Quick Effect: Synchro Summon during opponent's turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
    e1:SetTarget(s.syntg)
    e1:SetOperation(s.synop)
    c:RegisterEffect(e1)

    -- Quick Effect: Ritual Summon during either Main Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.rittg)
    e2:SetOperation(s.ritop)
    c:RegisterEffect(e2)
end

-----------------------
-- SYNCHRO SUMMON EFFECT
-----------------------
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil)
    local sc=g:GetFirst()
    if sc then
        Duel.SynchroSummon(tp,sc,nil)
        -- Give 500 ATK
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

-----------------------
-- RITUAL SUMMON EFFECT
-----------------------
function s.ritfilter(c,e,tp)
    return c:IsSetCard(0x103) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.matfilter(c)
    return (c:IsLevelAbove(1) or c:IsType(TYPE_LINK)) and c:IsReleasable()
end
function s.getTotalLevel(g)
    local total=0
    for tc in aux.Next(g) do
        total = total + (tc:IsType(TYPE_LINK) and tc:GetLink() or tc:GetLevel())
    end
    return total
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not rc then return end

    local lv=rc:GetLevel()
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)

    -- Select materials with total >= ritual monster's level
    local selected=aux.SelectUnselectGroup(mg,e,tp,nil,lv,
        function(g) return s.getTotalLevel(g)>=lv end,
        true,tp,HINTMSG_RELEASE,nil,nil,true)

    if #selected==0 then return end

    rc:SetMaterial(selected)
    Duel.Release(selected,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.BreakEffect()
    Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
    rc:CompleteProcedure()

    -- Draw 1 card if successful
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
end
