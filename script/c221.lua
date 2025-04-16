--Elemental HERO Artic Flare
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.fusionfilter,2)
    -- Gains FIRE Attribute on the field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(ATTRIBUTE_FIRE)
    c:RegisterEffect(e0)

    -- Draw up to 6 cards if Fusion Summoned with 2 or fewer in hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.drcon)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)

    -- Recovery on leave field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.rctg)
    e2:SetOperation(s.rcop)
    c:RegisterEffect(e2)
end

-- Fusion requirement: 2 E-HERO Fusion Monsters, 1 FIRE and 1 WATER
function s.fusionfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x3008,fc,sumtype,tp) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end

-- Draw condition
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local ct2=6-Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if chk==0 then return ct1>0 or ct2>0 end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,ct1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,ct2,1-tp,LOCATION_DECK)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local ct2=6-Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if ct1>0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
    if ct2>0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
end

-- Leave field effect: Add 1 E-HERO, shuffle other
function s.rcfilter(c)
    return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and not c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WATER) and c:IsAbleToHand()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.rcfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rcfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.rcfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local th=g:Select(tp,1,1,nil):GetFirst()
        g:RemoveCard(th)
        if th:IsRelateToEffect(e) then
            Duel.SendtoHand(th,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,Group.FromCards(th))
        end
        local td=g:GetFirst()
        if td and td:IsRelateToEffect(e) then
            Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
