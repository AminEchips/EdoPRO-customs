
--Condemned Goddess
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,35306215,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY))
    
    --Set 1 Spell/Trap from hand on Fusion Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)
    
    --Chain to Quick-Play Spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.qpcon)
    e2:SetTarget(s.qptg)
    e2:SetOperation(s.qpop)
    c:RegisterEffect(e2)

    --GY effect: revive if opponent controls negated card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Fusion Summon condition
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.setfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
end

-- Chain to Quick-Play Spell effect
function s.qpcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsType(TYPE_SPELL) and rc:IsQuickPlaySpell()
end
function s.qptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.qpop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)>0 then
        local g=Duel.GetMatchingGroup(Card.IsQuickPlaySpell,tp,LOCATION_HAND,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
            local sg=g:Select(tp,1,1,nil)
            local sc=sg:GetFirst()
            Duel.Hint(HINT_CARD,tp,sc:GetCode())
            Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            local te=sc:GetActivateEffect()
            if not te then return end
            local tg=te:GetTarget()
            local op=te:GetOperation()
            if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
            Duel.BreakEffect()
            if op then op(te,tp,eg,ep,ev,re,r,rp) end
        end
    end
end

-- GY revive effect
function s.negfilter(c)
    return c:IsFaceup() and c:IsDisabled()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1,true)
        end
    end
end
