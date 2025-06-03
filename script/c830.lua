--The Phantom Knights of Chosen Sword
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,4),2,nil,nil,nil,nil,false)
    c:EnableReviveLimit()
    --Alternative Xyz Summon with Rank 3 DARK Xyz Monster with no materials
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)
    --Gain ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Attach trap and bounce
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATTACH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.atcon)
    e2:SetTarget(s.attg)
    e2:SetOperation(s.atop)
    c:RegisterEffect(e2)
    --Detach to prevent destruction
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.reptg)
    c:RegisterEffect(e3)
end

-- Alternative Xyz Summon
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsRank(3) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()==0
end
function s.xyzcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.xyzfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        local mc=g:GetFirst()
        c:SetMaterial(Group.FromCards(mc))
        Duel.Overlay(c,Group.FromCards(mc))
    end
end

-- ATK Boost
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_ONFIELD,0,nil,0xdb)*200
end

-- Condition: banished trap(s)
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- Attach target
function s.atfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsAbleToOverlay()
end
function s.bouncetarget(c)
    return c:IsAbleToHand()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_ATTACH,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
-- Attach and optionally bounce
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        Duel.Overlay(c,Group.FromCards(tc))
        local g=Duel.GetMatchingGroup(s.bouncetarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
        end
    end
end

-- Destruction Replacement
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
    c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
    return true
end
