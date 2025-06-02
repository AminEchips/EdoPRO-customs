--Raidraptor - Apex Falcon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,11,3,s.ovfilter,aux.Stringid(id,0),3,nil)
    c:EnableReviveLimit()

    -- Unaffected by other card effects
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_IMMUNE_EFFECT)
    e0:SetValue(s.efilter)
    c:RegisterEffect(e0)

    -- Opponent's Special Summoned monsters lose 1000 ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetTarget(s.atktg)
    e1:SetValue(-1000)
    c:RegisterEffect(e1)

    -- Destroy opponent's Special Summoned monsters if ATK = 0
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Take control of opponent's Xyz Monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.ctrlcon)
    e3:SetCost(s.ctrlcost)
    e3:SetTarget(s.ctrltg)
    e3:SetOperation(s.ctrlop)
    c:RegisterEffect(e3)

    -- Second attack if it attacked a monster with lower ATK
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BATTLED)
    e4:SetCondition(s.extracon)
    e4:SetOperation(s.extraop)
    c:RegisterEffect(e4)
end

-- Xyz material must be "Raidraptor" monsters
function s.ovfilter(c)
    return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsLevel(11)
end

-- Unaffected by other cards' effects
function s.efilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end

-- Target opponent’s Special Summoned monsters
function s.atktg(e,c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

-- Destroy Special Summoned monsters with 0 ATK
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetAttack()==0
    end,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Condition: has a "Raidraptor" Xyz material
function s.ctrlcon(e)
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xba)
end

-- Cost: detach 2 materials
function s.ctrlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
end

-- Proper target filter
function s.ctrlfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(1-tp) and c:IsAbleToChangeControler()
end

-- Target for control effect
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ctrlfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

-- Operation for control
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetValue(0xba) -- Becomes "Raidraptor"
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- Second attack if it battled a monster with lower ATK
function s.extracon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsRelateToBattle() and bc:IsFaceup() and bc:GetAttack()<c:GetAttack()
end

-- Grant 1 additional attack
function s.extraop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
