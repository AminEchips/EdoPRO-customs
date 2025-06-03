--Dark Rebellion Insurrection Xyz Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,7,2)
    c:EnableReviveLimit()

    --Always treated as "The Phantom Knights"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(0x10db)
    c:RegisterEffect(e0)

    --Battle limitation + protection
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atklimitcon)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Attack restriction
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.atklimitcon)
    e3:SetValue(s.battlelimit)
    c:RegisterEffect(e3)

    --Quick Effect: Gain ATK, maybe double and negate
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
    e4:SetTarget(s.qetg)
    e4:SetOperation(s.qeop)
    c:RegisterEffect(e4)

    --Effect if "Dark Rebellion Xyz Dragon" is material: halve opponent’s monsters ATK except highest
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.halvecon)
    e5:SetOperation(s.halveop)
    c:RegisterEffect(e5)
end

-- Condition: Opponent controls a monster
function s.atklimitcon(e)
    return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end

-- Attack only the highest ATK monster your opponent controls
function s.battlelimit(e,c)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
    local maxatk=0
    for tc in g:Iter() do
        if tc:GetAttack()>maxatk then maxatk=tc:GetAttack() end
    end
    return c:GetAttack()<maxatk
end

-- Quick Effect: gain ATK = target's ATK; if not Xyz, gain original ATK again and negate
function s.qefilter(c,e,tp)
    return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.qefilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.qefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.qefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local val=tc:GetAttack()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)

        if not tc:IsType(TYPE_XYZ) then
            local val2=tc:GetBaseAttack()
            if val2>0 then
                local e2=e1:Clone()
                e2:SetValue(val2)
                c:RegisterEffect(e2)
            end
            -- non-targeting negate
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e3)
            local e4=e3:Clone()
            e4:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e4)
        end
    end
end

-- Halve ATK of all opponent’s monsters except the highest if Dark Rebellion Xyz is material
function s.halvecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
function s.halveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if #g<2 then return end
    local maxatk=0
    local top={}
    for tc in g:Iter() do
        local atk=tc:GetAttack()
        if atk>maxatk then
            maxatk=atk
            top={tc}
        elseif atk==maxatk then
            table.insert(top,tc)
        end
    end
    for tc in g:Iter() do
        if not aux.TableContains(top,tc) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(math.floor(tc:GetAttack()/2))
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end
