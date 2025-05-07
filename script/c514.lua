--Altergeist Codecuseleus
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

    -- Cannot be destroyed by battle
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Stardust-like Negate + Tribute Altergeist
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Return to field during End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.sumtg)
    e3:SetOperation(s.sumop)
    c:RegisterEffect(e3)

    -- Add or Special Summon Level 1 Spellcaster
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

-- Fusion materials
function s.matfilter1(c,fc,sumtype,tp)
    return c:IsSetCard(0x103,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
    return c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp) or c:IsType(TYPE_LINK,fc,sumtype,tp)
end

-- Negate condition
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
    local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
    return ex and tg and #tg>0 and tc+#tg:Filter(Card.IsOnField,nil)-#tg>0
end

-- Tribute 1 "Altergeist" monster
function s.cfilter(c)
    return c:IsSetCard(0x103) and c:IsReleasable()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
    Duel.Release(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
    e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,0)
end

-- Return to field during End Phase
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:HasFlagEffect(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Add or Special Summon Level 1 Spellcaster
function s.thfilter(c,e,tp)
    return c:IsLevel(1) and c:IsRace(RACE_SPELLCASTER) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not tc:IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end
