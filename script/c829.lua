--The Phantom Knights of Antique Axe
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,4,2)
    c:EnableReviveLimit()

    --Destroy Spells/Traps
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --Recycle Trap and Set 1 from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetCountLimit(1,{id,1})
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- e1 cost: detach up to 2
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    local ct=math.min(2,c:GetOverlayCount())
    c:RemoveOverlayCard(tp,1,ct,REASON_COST)
    e:SetLabel(ct)
end

-- e1 target
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=e:GetLabel()
    if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
    if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- e1 operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetsRelateToChain()
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- e2: trigger when destroys by battle
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_REMOVED,0,1,1,nil,TYPE_TRAP)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_TRAP)
        if #sg>0 then
            Duel.SSet(tp,sg)
        end
    end
end
