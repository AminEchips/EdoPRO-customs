--Evil HERO Malicious Void
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,236,22160245) -- Evil HERO Cosmos + Evil HERO Inferno Wing

    -- Must be Special Summoned with "Dark Fusion"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- Must attack if able
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MUST_ATTACK)
    c:RegisterEffect(e1)

    -- Cannot attack the turn it is Special Summoned (including Fusion Summoned)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonTurn() end)
    c:RegisterEffect(e2)

    -- Inflict damage if destroys by battle
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(aux.bdgcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Change to Attack Position
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetHintTiming(0,TIMING_END_PHASE)
    e4:SetCondition(s.poscon)
    e4:SetOperation(s.posop)
    c:RegisterEffect(e4)
end

s.listed_names={236,22160245,94820406}
s.material_setcode={0x3008}
s.listed_series={0x3008}
s.dark_calling=true

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    local val=math.max(bc:GetBaseAttack(),bc:GetBaseDefense())+2100
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        local val=math.max(bc:GetBaseAttack(),bc:GetBaseDefense())+2100
        Duel.Damage(1-tp,val,REASON_EFFECT)
    end
end

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        if tc:IsFacedown() or tc:IsDefensePos() then
            Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
        end
    end
end

