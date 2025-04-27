--Black Souls Whirlwind
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and optionally use an effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- If this card leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.lftg)
    e2:SetOperation(s.lfop)
    c:RegisterEffect(e2)
end
s.listed_names={91349449} -- Black Whirlwind
s.listed_series={0x33} -- Blackwing

--------------------------------------------------------
-- Optional activate
--------------------------------------------------------

-- Filter for monsters that can be negated
function s.negfilter(c)
    return c:IsFaceup() and not (c:IsDisabled() or c:IsImmuneToEffect(EFFECT_DISABLE))
end

-- Filter for Blackwing Level 5 or lower Synchro Monsters
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,0,1,nil) 
         and Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

    if not (b1 or b2) then return end

    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local opt=0
        if b1 and b2 then
            opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        elseif b1 then
            opt=Duel.SelectOption(tp,aux.Stringid(id,3))
        else
            opt=Duel.SelectOption(tp,aux.Stringid(id,4))+1
        end

        if opt==0 then
            -- negate
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local g1=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_MZONE,0,1,1,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local g2=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
            local g=g1
            g:Merge(g2)
            for tc in aux.Next(g) do
                if tc:IsFaceup() and tc:IsRelateToEffect(e) then
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    tc:RegisterEffect(e1)
                    local e2=Effect.CreateEffect(e:GetHandler())
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_DISABLE_EFFECT)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    tc:RegisterEffect(e2)
                end
            end
        elseif opt==1 then
            -- special summon
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
            if #g>0 then
                Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

--------------------------------------------------------
-- Leave field effect
--------------------------------------------------------
function s.whirlwindfilter(c)
    return c:IsCode(91349449) and c:IsSSetable()
end

function s.bwfilter(c)
    return c:IsSetCard(0x33) and c:IsSummonable(true,nil)
end

function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.whirlwindfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.bwfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.lfop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.whirlwindfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
        local g=Duel.SelectMatchingCard(tp,s.bwfilter,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 then
            Duel.Summon(tp,g:GetFirst(),true,nil,1) -- Normal Summon without tributing
        end
    end
end
