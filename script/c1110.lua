--Salamangreat Hare
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,2,s.matcheck)
    c:EnableReviveLimit()

    -- Cannot be targeted for attacks
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.atklimit)
    c:RegisterEffect(e1)

    -- Reincarnation movement + bounce
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.reincon)
    e2:SetTarget(s.movtg)
    e2:SetOperation(s.movop)
    c:RegisterEffect(e2)

    -- On destruction: shuffle "Salamangreat" cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.shcon)
    e3:SetTarget(s.shtg)
    e3:SetOperation(s.shop)
    c:RegisterEffect(e3)
end
s.listed_series={0x119}

-- Material check
function s.matcheck(g,lc,sumtype,tp)
    return g:FilterCount(Card.IsType,nil,TYPE_EFFECT)==#g
end

-- Cannot be selected for battle if you point to another "Salamangreat"
function s.atklimit(e,c)
    return e:GetHandler():IsHasCardTarget(c)
end

-- Reincarnation check
function s.reincon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsReincarnationSummoned()
end

-- Move to another zone & bounce
function s.movtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.CheckLocation(tp,LOCATION_MZONE,0)
        or Duel.CheckLocation(tp,LOCATION_MZONE,1)
        or Duel.CheckLocation(tp,LOCATION_MZONE,2)
        or Duel.CheckLocation(tp,LOCATION_MZONE,3)
        or Duel.CheckLocation(tp,LOCATION_MZONE,4) end
end
function s.movop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~0)
    local nzone=math.log(zone,2)
    if Duel.MoveSequence(c,nzone)==0 then return end

    -- Bounce all monsters in same column (except this card)
    local g=Duel.GetMatchingGroup(s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetColumnGroup())
    if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end

    -- Then return 1 "Salamangreat" monster you control to the hand
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.salafilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #sg>0 then Duel.SendtoHand(sg,nil,REASON_EFFECT) end
end

function s.colfilter(c,colgrp)
    return colgrp:IsContains(c)
end
function s.salafilter(c)
    return c:IsSetCard(0x119) and c:IsAbleToHand()
end

-- Destruction condition
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_EFFECT+REASON_BATTLE)~=0
end

function s.shfilter(c)
    return c:IsSetCard(0x119) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if chk==0 then return ct>0
        and Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
