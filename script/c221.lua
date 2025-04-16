--Elemental HERO Arctic Flare
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Must be Fusion Summoned using 1 FIRE and 1 WATER Elemental HERO Fusion
    Fusion.AddProcMix(c,true,true,s.ffilter_fire,s.ffilter_water)

    -- Draw up to 6 if you have 2 or fewer cards in hand
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

    -- GY Recovery
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.rctg)
    e2:SetOperation(s.rcop)
    c:RegisterEffect(e2)

    -- Also treated as FIRE while face-up
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ADD_ATTRIBUTE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(ATTRIBUTE_FIRE)
    c:RegisterEffect(e3)
end

-- Fusion filters
function s.ffilter_fire(c)
    return c:IsFusionType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.ffilter_water(c)
    return c:IsFusionType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsAttribute(ATTRIBUTE_WATER)
end

-- Draw effect
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,nil)<=2
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local ct=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    if ct>0 then
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end

-- GY Recovery
function s.thfilter(c)
    return c:IsSetCard(0x3008) and c:IsAbleToHand() and not c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local th=g:Select(tp,1,1,nil):GetFirst()
    g:RemoveCard(th)
    if th and Duel.SendtoHand(th,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,th)
    end
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
