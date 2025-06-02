--The Phantom Knights of Cursed Swords
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Discard 1 card; Set 1 "Phantom Knights" Spell from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.setcost)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Effect 2: Detached from DARK Xyz monster's effect → recover banished Phantom Knights Trap
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)

    -- Effect 3: GY boost for "The Phantom Knights" monsters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(aux.bfgcost)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-------------------------------
-- Effect 1 - Set a Spell
-------------------------------
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.setfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsSetCard(0xdb) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g:GetFirst()) end
end

-------------------------------
-- Effect 2 - Recover Trap when detached
-------------------------------
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_OVERLAY)
        and re and re:IsActivated() and re:IsMonsterEffect()
        and re:GetHandler():IsAttribute(ATTRIBUTE_DARK)
end

function s.trapfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xdb) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.trapfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.trapfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.trapfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end

-------------------------------
-- Effect 3 - ATK boost from GY
-------------------------------
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x10db)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(800)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
