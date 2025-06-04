--The Phantom Knights of Ghastly Shells
local s,id=GetID()
function s.initial_effect(c)
    -- Activate & Summon as Monster when attack is declared on PK monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Trigger: Opponent attacks your "Phantom Knights" monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    local tg=Duel.GetAttackTarget()
    return tg and tg:IsControler(tp) and tg:IsSetCard(0x10db)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttacker()
    if not tc or not tc:IsRelateToBattle() or not c:IsRelateToEffect(e) then return end

    -- Negate attack
    if Duel.NegateAttack() then
        -- Set ATK to 0 until end of NEXT turn
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)
    end

    -- Become Monster
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10db,TYPES_EFFECT_MONSTER,0,0,4,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
    c:AddMonsterAttribute(TYPE_EFFECT+TYPE_MONSTER)
    Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)

    -- Gain Quick Effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_END)
    e2:SetTarget(s.qetg)
    e2:SetOperation(s.qeop)
    c:RegisterEffect(e2,true)
end

-- Filter for "Phantom Knights" monster or continuous spell/trap
function s.qefilter(c)
    return c:IsFaceup() and c:IsSetCard(0x10db) and (c:IsType(TYPE_CONTINUOUS+TYPE_SPELL+TYPE_TRAP) or c:IsType(TYPE_MONSTER)) and c:IsAbleToGrave()
end
-- Filter for Rebellion Xyz in GY
function s.rebfilter(c,e,tp)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.qefilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
            and Duel.IsExistingMatchingCard(s.rebfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.qefilter,tp,LOCATION_ONFIELD,0,1,1,c)
    if #g==0 or not c:IsRelateToEffect(e) then return end
    g:AddCard(c)
    if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.rebfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
