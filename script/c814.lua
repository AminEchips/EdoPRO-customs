--Raidraptor - Apex Falcon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,11,3,s.ovfilter,aux.Stringid(id,0),3,nil)
    c:EnableReviveLimit()

    -- Unaffected by other cards' effects
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_IMMUNE_EFFECT)
    e0:SetValue(s.efilter)
    c:RegisterEffect(e0)

    -- ATK reduction + destruction
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetTarget(s.atktg)
    e1:SetValue(-1000)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Take control of opponent's Xyz Monster (once per turn)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.ctrlcon)
    e3:SetCost(s.ctrlcost)
    e3:SetTarget(s.ctrltg)
    e3:SetOperation(s.ctrlop)
    c:RegisterEffect(e3)

    -- Second attack if it attacked a lower ATK monster
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_EXTRA_ATTACK)
    e4:SetCondition(s.extracon)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

-- Must have 3 Raidraptor monsters
function s.ovfilter(c)
    return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsLevel(11)
end

-- Unaffected by other effects
function s.efilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end

-- Target opponent's Special Summoned monsters for -1000 ATK
function s.atktg(e,c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

-- Destroy opponent's Special Summoned monsters with 0 ATK
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetAttack()==0
    end,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Condition: must have a Raidraptor Xyz as material
function s.ctrlcon(e)
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xba)
end

-- Cost: detach 2
function s.ctrlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
    c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

-- Take control of 1 Xyz monster opponent controls
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_XYZ) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_XYZ) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_XYZ)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetValue(0xba) -- treat as Raidraptor
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- Extra attack if it destroyed a lower ATK monster in battle
function s.extracon(e)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsRelateToBattle() and bc:IsFaceup() and bc:GetAttack()<c:GetAttack()
end
