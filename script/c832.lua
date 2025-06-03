--The Phantom Knights of Black Sabbath Sword
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,function(c) return c:IsSetCard(0x10db) end,5,3)
    c:EnableReviveLimit()

    --Can activate Trap cards from hand if name matches attached card
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetRange(LOCATION_MZONE)
    e0:SetTargetRange(LOCATION_HAND,0)
    e0:SetCondition(s.trapcon)
    e0:SetTarget(s.traptg)
    c:RegisterEffect(e0)

    --Once per turn: target Set card or DEF monster, banish or attach
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.attachtg)
    e1:SetOperation(s.attachop)
    c:RegisterEffect(e1)

    --Quick Effect: detach and pop in response to opponent activation
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.popcon)
    e2:SetCost(s.popcost)
    e2:SetTarget(s.poptg)
    e2:SetOperation(s.popop)
    c:RegisterEffect(e2)
end

-- Trap from hand condition: must share name with material
function s.trapcon(e)
    return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.traptg(e,c)
    local mat=e:GetHandler():GetOverlayGroup()
    return c:IsType(TYPE_TRAP) and mat:IsExists(Card.IsCode,1,nil,c:GetOriginalCode())
end

-- Target 1 set card or DEF position monster
function s.attachfilter(c)
    return (c:IsFacedown() or (c:IsPosition(POS_DEFENSE))) and c:IsAbleToRemove()
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.attachfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0: Banish, 1: Attach
        if opt==0 then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        else
            Duel.Overlay(c,Group.FromCards(tc))
        end
    end
end

-- Quick Effect condition: respond to opponent activation
function s.popcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActivated()
end
function s.popcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.poptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.popop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
