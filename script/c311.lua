--Darklord Lillia
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),4,2,s.ovfilter,aux.Stringid(id,0),2)
    c:EnableReviveLimit()

    -- Effect 1: Detach 1 + discard 1, then random discard from opponent, both draw, gain LP
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- Effect 2: If sent to GY to activate a Darklord S/T effect, LP cost is halved
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetOperation(s.halveop)
    c:RegisterEffect(e2)

    -- Effect 3: Banish from GY to search Level 8 Darklord
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.listed_series={0xef}

function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end

-- Effect 1
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
        and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
        and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local opp_hand=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
    if #opp_hand==0 then return end
    local sg=opp_hand:RandomSelect(tp,1)
    Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
    local p1=Duel.Draw(tp,1,REASON_EFFECT)
    local p2=Duel.Draw(1-tp,1,REASON_EFFECT)
    if p1>0 then Duel.Recover(tp,Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*100,REASON_EFFECT) end
    if p2>0 then Duel.Recover(1-tp,Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*100,REASON_EFFECT) end
end

-- Effect 2: Halve LP costs this turn (if sent to GY to activate a Darklord S/T)
function s.halveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsReason(REASON_COST) or not re then return end
    if re:GetHandler():IsSetCard(0xef) and re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CHANGE_LPCOST)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetValue(s.costchange)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.costchange(e,rp,val)
    if rp==e:GetHandlerPlayer() then
        return math.ceil(val/2)
    else return val end
end

-- Effect 3: Banish to search Level 8 Darklord
function s.thfilter(c)
    return c:IsSetCard(0xef) and c:IsLevel(8) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
