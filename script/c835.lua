--The Phantom Knights' Life Stream Launch
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Cannot negate activation of your Xyz Summon effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    --Prevent opponent from responding to Xyz Summon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.limcon)
    e3:SetOperation(s.limop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_END)
    e4:SetRange(LOCATION_SZONE)
    e4:SetOperation(s.limop2)
    c:RegisterEffect(e4)

    --Search on Xyz Summon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1,{id,0})
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
end

-- Make sure Xyz-related effects can't be negated
function s.efilter(e,ct)
    local tp=e:GetHandlerPlayer()
    local te,rp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
    return tp==rp and te:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and te:IsHasType(EFFECT_TYPE_ACTIONS) and te:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP)
end

-- Opponent cannot activate cards/effects during your Xyz Summon
function s.limfilter(c,tp)
    return c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentChain()==0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    elseif Duel.GetCurrentChain()==1 then
        e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAINING)
        e1:SetOperation(s.resetop)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EVENT_BREAK_EFFECT)
        e2:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():ResetFlagEffect(id)
    e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetFlagEffect(id)>0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    end
    e:GetHandler():ResetFlagEffect(id)
end
function s.chainlm(e,rp,tp)
    return tp==rp
end

-- Search effect when Xyz Summoning an Xyz Monster
function s.cfilter(c,tp)
    return c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfilter(c)
    return (c:IsSetCard(0x99) or c:IsSetCard(0x10db)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
