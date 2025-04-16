--Elemental HERO Artic Flare
local s,id=GetID()
function s.initial_effect(c)
    -- Must be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,2)
    
    -- Treated as FIRE while face-up
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(ATTRIBUTE_FIRE)
    c:RegisterEffect(e0)

    -- Draw until 6 if 2 or less in hand
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

    -- Recycle and add on leaving field
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
end

s.material_setcode={0x3008}

function s.matfilter(c,scard,sumtype,tp)
    return c:IsSetCard(0x3008,scard,sumtype,tp) and c:IsType(TYPE_FUSION)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=2
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,6) or Duel.IsPlayerCanDraw(1-tp,6) end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local p2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if p1<6 then Duel.Draw(tp,6-p1,REASON_EFFECT) end
    if p2<6 then Duel.Draw(1-tp,6-p2,REASON_EFFECT) end
end

function s.rcfilter(c)
    return c:IsSetCard(0x3008) and not c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_WATER) and c:IsAbleToHand()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rcfilter,tp,LOCATION_GRAVE,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.rcfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local th=g:Select(tp,1,1,nil):GetFirst()
    g:RemoveCard(th)
    if Duel.SendtoHand(th,nil,REASON_EFFECT)>0 and #g>0 then
        Duel.BreakEffect()
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
