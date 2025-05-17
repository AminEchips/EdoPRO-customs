--Tri-Brigade Air Stand
--Scripted by Meuh
local s,id=GetID()

function s.initial_effect(c)
    --Activate: Reveal Tri-Brigade, send Extra, SS, draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --GY effect: Add self or revive if Link banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.gycon)
    e2:SetCost(s.gycost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end
s.listed_series={0x14f}

-- Effect 1
function s.cfilter(c)
    return c:IsSetCard(0x14f) and c:IsMonster() and c:IsAbleToHand()
end
function s.exfilter(c)
    return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g1==0 then return end
    local rc=g1:GetFirst()
    Duel.ConfirmCards(1-tp,rc)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,function(c)
        return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK)
            and c:IsRace(rc:GetRace()) and c:IsAbleToGrave()
    end,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g2==0 then return end
    Duel.SendtoGrave(g2,REASON_EFFECT)

    if Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP) > 0 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

-- Effect 2
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_LINK)
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.gyfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsAbleToDeck()
        and (c:IsCanBeSpecialSummoned(nil,0,tp,false,false) or c:IsAbleToDeck())
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.gyfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local b1 = tc:IsAbleToDeck()
    local b2 = tc:IsCanBeSpecialSummoned(e,0,tp,false,false)

    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        op=0
    elseif b2 then
        op=1
    else return end

    if op==0 then
        if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
        end
    else
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
