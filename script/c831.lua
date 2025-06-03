--The Phantom Knights of Burial Bludgeon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),5,2)
    c:EnableReviveLimit()

    --Detach to activate 1 of 2 effects (Quick if has PK material)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    --Quick effect clone if PK material
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCondition(s.quickcon)
    c:RegisterEffect(e2)

    --Floating effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.discon)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end

--Detach 1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--Choose effect
function s.tgfilter(c)
    return c:IsSetCard(0x10db) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
    local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
    if not (b1 or b2) then return end

    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
        op=0
    else
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
        op=1
    end

    if op==0 then
        --Destroy + GY negate (non-targeting)
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 then
                local tc=sg:GetFirst()
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                tc:RegisterEffect(e2)
            end
        end
    else
        --Target "Phantom Knights" in GY, shuffle + draw
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
            Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
            Duel.BreakEffect()
            local tc=g:GetFirst()
            if tc:IsRelateToEffect(e) then
                Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    end
end

--Check for PK material
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
end

--Floating effect (non-targeting)
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g>0 then
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
