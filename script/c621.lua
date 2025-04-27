--Black Souls Whirlwind
local s,id=GetID()
function s.initial_effect(c)
    --Activate and apply effects
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --If this card leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOFIELD+CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.lfcon)
    e2:SetTarget(s.lftg)
    e2:SetOperation(s.lfop)
    c:RegisterEffect(e2)
end

s.listed_names={91351370} -- Black Whirlwind
s.listed_series={0x33} -- Blackwing archetype

-------------------------------------------------
-- Activation choice
-------------------------------------------------
function s.negfilter(c)
    return c:IsFaceup() and c:IsCanBeDisabled()
end
function s.bwfilter(c)
    return c:IsSetCard(0x33) and c:IsSummonable(true,nil)
end
function s.synfilter(c)
    return c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_MZONE,1,nil)
    local b3=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_GRAVE,0,1,nil)
    if not (b1 and b2) and not b3 then return end

    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
    local opt=0
    if (b1 and b2) and b3 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif (b1 and b2) then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2))
    else
        opt=Duel.SelectOption(tp,aux.Stringid(id,3))
        opt=opt+1
    end

    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g1=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g2=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
        local g=g1+g2
        for tc in aux.Next(g) do
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-------------------------------------------------
-- When this card leaves the field
-------------------------------------------------
function s.lfcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsFaceup()
end
function s.whirlwindfilter(c)
    return c:IsCode(91351370) and not c:IsForbidden()
end
function s.bwhandfilter(c)
    return c:IsSetCard(0x33) and c:IsSummonable(true,nil)
end
function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.whirlwindfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.bwhandfilter,tp,LOCATION_HAND,0,1,nil)
    end
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.whirlwindfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        Duel.BreakEffect()
        if Duel.IsExistingMatchingCard(s.bwhandfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local g=Duel.SelectMatchingCard(tp,s.bwhandfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #g>0 then
                local c=g:GetFirst()
                -- Allow summon without tribute
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SUMMON_PROC)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCondition(aux.SumCondition())
                e1:SetOperation(aux.SumOperation())
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                c:RegisterEffect(e1)
                Duel.Summon(tp,c,true,nil)
            end
        end
    end
end
