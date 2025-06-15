--Salamangreat Hare
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,2,s.matcheck)

    -- Monsters this card points to cannot be selected for attacks
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.battletarget)
    c:RegisterEffect(e1)

    -- Move to an adjacent zone (Reincarnation only)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(function(e) return e:GetHandler():IsReincarnationSummoned() and aux.seqmovcon(e) end)
    e2:SetOperation(aux.seqmovop)
    c:RegisterEffect(e2)

    -- Ignition: Column bounce + optional Salamangreat return (Reincarnation only)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(e) return e:GetHandler():IsReincarnationSummoned() end)
    e3:SetOperation(s.colop)
    c:RegisterEffect(e3)

    -- On destroy: shuffle up to opponent's hand size of Salamangreats into Deck
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(function(e) return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) end)
    e4:SetTarget(s.shtg)
    e4:SetOperation(s.shop)
    c:RegisterEffect(e4)
end
s.listed_series={0x119}

-- Only FIRE Effect monsters
function s.matcheck(g,lc,sumtype,tp)
    return g:FilterCount(Card.IsType,nil,TYPE_EFFECT)==#g
end

-- Protection effect: monsters Hare points to
function s.battletarget(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end

-- Column bounce + optional Salamangreat return
function s.colop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end

    -- Return all other monsters in same column
    local colgrp=c:GetColumnGroup():Filter(function(tc) return tc~=c end,nil)
    if #colgrp>0 then
        Duel.SendtoHand(colgrp,nil,REASON_EFFECT)
    end

    -- Optional: return 1 Salamangreat you control
    local g=Duel.GetMatchingGroup(function(tc)
        return tc:IsSetCard(0x119) and tc:IsAbleToHand()
    end,tp,LOCATION_MZONE,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
    end
end

-- Shuffle effect
function s.shfilter(c)
    return c:IsSetCard(0x119) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
