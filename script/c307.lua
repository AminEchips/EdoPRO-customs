--Darklord Beelze
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcFunRep(c,s.ffilter,2,true)

    -- Effect 1: LP-paid trigger: ATK +1000 & extra attack (once per turn)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.bonusop)
    c:RegisterEffect(e1)

    -- Effect 2: If 1 Darklord S/T would be shuffled into Deck, add to hand instead
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.repcon)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)

    -- Effect 3: GY revive by sending 2 Darklords
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,3})
    e3:SetCondition(aux.exccon)
    e3:SetCost(s.gycost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end
s.listed_series={0xef}

-- Fusion material: 2 Level 5+ "Darklord" monsters
function s.ffilter(c,fc,sub,mg,sg,chkfn)
    return c:IsSetCard(0xef) and c:IsLevelAbove(5)
end

--------------------------------------------------------------
-- Effect 1: Gain 1000 ATK and 1 extra attack if LP was paid
--------------------------------------------------------------
function s.bonusop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or c:GetFlagEffect(id)>0 then return end
    if not re then return end
    local lpCost = re:GetCost()
    if rp==tp and re and re:GetHandler() and re:GetHandler():IsSetCard(0xef) then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)

        -- Gain 1000 ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)

        -- Extra attack
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end

--------------------------------------------------------------
-- Effect 2: Replace shuffle of exactly 1 Darklord S/T from GY
--------------------------------------------------------------
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.repfilter,nil,tp)
    return #g==1
end
function s.repfilter(c,tp)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsLocation(LOCATION_DECK) and c:IsPreviousLocation(LOCATION_GRAVE)
        and c:IsControler(tp) and c:IsAbleToHand()
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

--------------------------------------------------------------
-- Effect 3: GY revive by sending 2 "Darklord" cards
--------------------------------------------------------------
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
