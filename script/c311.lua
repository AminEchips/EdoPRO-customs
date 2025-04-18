--Darklord Lillia
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon Procedure
    Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()

    -- Effect 1: Detach + discard, opponent random discard, draw & recover
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- Effect 2 (Trigger): If sent to GY as cost for a Darklord Spell/Trap, flag for halving LP cost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.halvecon)
    e2:SetOperation(s.setreg)
    c:RegisterEffect(e2)

    -- Effect 2b (Continuous): After chain resolves, apply halving LP effect if flagged
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetOperation(s.halveop)
    c:RegisterEffect(e3)

    -- Effect 3: Banish from GY to add 1 Level 8 "Darklord" from Deck to hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end
s.listed_series={0xef}

function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end

-- Effect 1: Discard combo
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

-- Effect 2a: Check if sent as cost for Darklord S/T
function s.halvecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local re=c:GetReasonEffect()
    local rc=re and re:GetHandler()
    return c:IsReason(REASON_COST) and re and rc:IsSetCard(0xef) and rc:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.setreg(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end

-- Effect 2b: Apply LP halving effect after resolution if flagged
function s.halveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetFlagEffect(id)==0 then return end
    c:ResetFlagEffect(id)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_LPCOST)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.costchange)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.costchange(e,re,rp,val)
    if val == nil then return val end  -- Always guard nil
    if rp == e:GetOwnerPlayer() then  -- Use GetOwnerPlayer, not GetHandlerPlayer
        return math.ceil(val / 2)
    end
    return val
end


-- Effect 3: Search Level 8 "Darklord"
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
