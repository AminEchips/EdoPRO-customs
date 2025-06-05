--The Phantom Knights of Ghastly Shells
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and become monster after attack negation
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Quick Effect while treated as monster: send self + 1 face-up PK card to SS "Rebellion"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.qecond)
    e2:SetCost(s.qecost)
    e2:SetTarget(s.qetg)
    e2:SetOperation(s.qeop)
    c:RegisterEffect(e2)
end

-- When opponent attacks a PK monster you control
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    local def=Duel.GetAttackTarget()
    return def and def:IsControler(tp) and def:IsSetCard(0x10db)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local c=e:GetHandler()
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10db,TYPES_EFFECT+TYPE_TRAP,0,0,4,RACE_WARRIOR,ATTRIBUTE_DARK)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    local c=e:GetHandler()
    if not Duel.NegateAttack() then return end
    Duel.BreakEffect()
    if atk:IsRelateToBattle() and atk:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        atk:RegisterEffect(e1)
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not c:IsRelateToEffect(e)
        or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10db,TYPES_EFFECT+TYPE_TRAP,0,0,4,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
    c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
    Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP_DEFENSE)
    c:AddMonsterAttributeComplete()
    Duel.SpecialSummonComplete()
end

-- Only allow monster effect if summoned by its own effect
function s.qecond(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end

-- Cost: this card + 1 face-up PK monster or Continuous S/T
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x10db) and c:IsAbleToGraveAsCost()
        and (c:IsType(TYPE_MONSTER) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)))
end
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c)
    g:AddCard(c)
    Duel.SendtoGrave(g,REASON_COST)
end

-- Rebellion Xyz filter
function s.rebfilter(c,e,tp)
    return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.rebfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rebfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
