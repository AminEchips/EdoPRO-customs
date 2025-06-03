--The Phantom Knights of Antique Axe
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
    c:EnableReviveLimit()

    --Destroy Spells/Traps
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --Battle: Retrieve and optionally Set
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(aux.bdocon)
    e2:SetOperation(s.batop)
    c:RegisterEffect(e2)
end

-- First Effect: Destroy Spells/Traps
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    local ct=math.min(2,c:GetOverlayCount())
    c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
    e:SetLabel(ct)
end
function s.destfilter(c)
    return c:IsSpellTrap() and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=e:GetLabel()
    if chkc then return chkc:IsOnField() and s.destfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.destfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.destfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Second Effect: Retrieve and Set
function s.banishedTrapFilter(c)
    return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.banishableSTFilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.settableTrapFilter(c)
    return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.batop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.banishedTrapFilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        -- Optional effect: Banish and Set
        if Duel.IsExistingMatchingCard(s.banishableSTFilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.settableTrapFilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local bg=Duel.SelectMatchingCard(tp,s.banishableSTFilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
            if #bg>0 and Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                local sg=Duel.SelectMatchingCard(tp,s.settableTrapFilter,tp,LOCATION_GRAVE,0,1,1,nil)
                if #sg>0 then
                    Duel.SSet(tp,sg)
                end
            end
        end
    end
end
