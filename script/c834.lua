--Dark Rebellion Insurrection Xyz Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon: 2 Rank 7 Xyz Monsters
    Xyz.AddProcedure(c,function(c) return c:IsRank(7) and c:IsType(TYPE_XYZ) end,7,2)
    c:EnableReviveLimit()

    --Always treated as "The Phantom Knights"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(0x10db)
    c:RegisterEffect(e0)

    --Cannot be destroyed by card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    --Attack restriction: must attack opponent’s highest ATK monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atklimitcon)
    e2:SetValue(s.atklimit)
    c:RegisterEffect(e2)

    --Quick Effect: Gain ATK, optionally double + negate (non-targeting)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
    e3:SetOperation(s.qeop)
    c:RegisterEffect(e3)

    --Effect if "Dark Rebellion Xyz Dragon" is material: halve ATK of all but strongest
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.halvecon)
    e4:SetOperation(s.halveop)
    c:RegisterEffect(e4)
end

-- Only attack opponent's highest ATK monster
function s.atklimitcon(e)
    return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
function s.atklimit(e,c)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
    local maxatk=0
    for tc in g:Iter() do
        maxatk=math.max(maxatk,tc:GetAttack())
    end
    return c:GetAttack()<maxatk
end

-- Quick Effect: Gain ATK permanently, optionally double + negate if not Xyz
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if not tc or not tc:IsFaceup() then return end

    local atk=tc:GetAttack()
    if atk>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end

    if not tc:IsType(TYPE_XYZ) then
        local batk=tc:GetBaseAttack()
        if batk>0 then
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(batk)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e2)
        end
        -- Non-targeting negate
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
        local e4=e3:Clone()
        e4:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e4)
    end
end

-- If "Dark Rebellion Xyz Dragon" is material
function s.halvecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
function s.halveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if #g<2 then return end
    -- Get max ATK value
    local maxatk=0
    local strongest=Group.CreateGroup()
    for tc in g:Iter() do
        local atk=tc:GetAttack()
        if atk>maxatk then
            strongest:Clear()
            strongest:AddCard(tc)
            maxatk=atk
        elseif atk==maxatk then
            strongest:AddCard(tc)
        end
    end
    -- Halve ATK of all except strongest
    for tc in g:Iter() do
        if not strongest:IsContains(tc) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(math.floor(tc:GetAttack()/2))
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end
