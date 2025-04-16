--Elemental HERO Arctic Flare
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
    
    -- Also treated as FIRE
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(ATTRIBUTE_FIRE)
    c:RegisterEffect(e0)

    -- Draw until 6 if you have 2 or fewer when Fusion Summoned
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

    -- Add 1 to hand and shuffle 1 if it leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.tg)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
end

s.listed_series={0x3008}

-- Fusion Material Filters
function s.matfilter1(c,fc,sumtype,tp)
    return c:IsFusionSetCard(0x3008) and c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
    return c:IsFusionSetCard(0x3008) and c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp)
end

-- Draw Effect Condition
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2
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

-- Leave Field Recovery
function s.tgfilter(c)
    return c:IsSetCard(0x3008) and not c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
        and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then 
        return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,2,nil) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tohand=g:Select(tp,1,1,nil):GetFirst()
    g:RemoveCard(tohand)
    if Duel.SendtoHand(tohand,nil,REASON_EFFECT)>0 and #g>0 then
        Duel.BreakEffect()
        Duel.SendtoDeck(g:GetFirst(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
