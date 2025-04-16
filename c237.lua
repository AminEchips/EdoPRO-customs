--Evil HERO Supreme Cosmos
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Must be Special Summoned with "Dark Fusion"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- Cannot be targeted by opponent's monster effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(s.tgval)
    c:RegisterEffect(e1)

    -- Banish 1 monster and add 1 HERO/Fiend
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- Return to Extra Deck during the End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end
s.listed_series={0x6008} -- Evil HERO
s.listed_names={94820406} -- Dark Fusion

function s.tgval(e,re,rp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+SUMMON_TYPE_FUSION)
end

function s.rmfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end

function s.thfilter(c)
    return (c:IsRace(RACE_FIEND) or c:IsSetCard(0x8)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #tg>0 then
            Duel.SendtoHand(tg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tg)
        end
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
