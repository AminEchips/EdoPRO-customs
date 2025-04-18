--Darklord Beelze
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcFunRep(c,s.ffilter,2,true)

    -- Gains 1000 ATK and 2 attacks if you paid LP this turn
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

    -- Replace shuffling of exactly 1 Darklord S/T from GY into Deck with adding it to hand
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.repcon)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    -- GY effect: Send 2 Darklords from hand/field to revive this, banish on leave
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

-- Fusion materials: 2 Level 5+ "Darklord" monsters
function s.ffilter(c,fc,sub,mg,sg,chkfn)
    return c:IsSetCard(0xef) and c:IsLevelAbove(5)
end

-- Check if player paid LP this turn
function s.atkcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

-- Track LP payment this turn
local echeck=Effect.CreateEffect(s)
echeck:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
echeck:SetCode(EVENT_PAY_LPCOST)
echeck:SetOperation(function(_,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) end)
Duel.RegisterEffect(echeck,0)

-- Replacement effect: Add S/T instead of shuffle if exactly 1
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.repfilter,1,nil,tp)
end
function s.repfilter(c,tp)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsLocation(LOCATION_DECK) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp)
        and c:GetReason()==REASON_EFFECT and Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,tp)==1
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.repfilter,nil,tp)
    if #g==1 and g:GetFirst():IsAbleToHand() then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleDeck(tp)
    end
end

-- GY effect: revive self by sending 2 "Darklord" cards
function s.gyfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToGraveAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end
