--Raidraptor - Sanctuary
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Draw 2 if you control 3+ "Raidraptor"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id) -- Hard once per turn (shared)
    e1:SetCondition(s.drcon)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)

    -- GY effect: Banish self, draw 2, place 2 back
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id) -- Same ID to enforce shared once per turn
    e2:SetCondition(s.grcon)
    e2:SetCost(s.grcost)
    e2:SetTarget(s.grtg)
    e2:SetOperation(s.grop)
    c:RegisterEffect(e2)
end

-- Filter for 3+ face-up Raidraptor monsters
function s.rrfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xba)
end

-- Condition: you control 3 or more Raidraptor monsters
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(s.rrfilter,tp,LOCATION_MZONE,0,nil)>=3
end

-- Draw 2 cards
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

-- GY condition: same as above
function s.grcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(s.rrfilter,tp,LOCATION_MZONE,0,nil)>=3
end

-- Cost: banish self
function s.grcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Target: draw 2
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2 end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

-- Operation: draw 2, return 2 to top of Deck
function s.grop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,2,REASON_EFFECT)~=2 then return end
    Duel.ShuffleHand(tp)
    Duel.BreakEffect()
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
    if #g==2 then
        Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
        Duel.SortDecktop(tp,tp,2)
    end
end
