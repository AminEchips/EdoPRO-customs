--Darklord Beelze
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcFunRep(c,s.ffilter,2,true)

    -- Gains 1000 ATK and 2 attacks if LP was paid this turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(1000)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Replace shuffle of exactly 1 Darklord S/T from GY into Deck with adding to hand
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.repcon)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- GY revive: Send 2 "Darklord" cards to SS this, banish on leave
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(aux.exccon)
    e4:SetCost(s.gycost)
    e4:SetTarget(s.gytg)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)
end
s.listed_series={0xef}

-- Fusion materials: 2 Level 5+ Darklords
function s.ffilter(c,fc,sub,mg,sg,chkfn)
    return c:IsSetCard(0xef) and c:IsLevelAbove(5)
end

-- ATK/Attack boost condition
function s.atkcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

-- Shuffle replacement condition
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.repfilter,nil,tp)
    return #g==1
end
function s.repfilter(c,tp)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsPreviousLocation(LOCATION_GRAVE)
        and c:IsLocation(LOCATION_DECK) and c:IsControler(tp) and c:IsAbleToHand()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.repfilter,nil,tp)
    if #g==1 then
        local tc=g:GetFirst()
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
        Duel.ShuffleDeck(tp)
    end
end

-- GY revive cost
function s.gyfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToGraveAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

-- GY revive target
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- GY revive operation
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end

-- Global LP cost tracker
local ge1=Effect.CreateEffect()
ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
ge1:SetCode(EVENT_PAY_LPCOST)
ge1:SetOperation(function(_,tp,_,_,_,_,_,_) Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) end)
Duel.RegisterEffect(ge1,0)
