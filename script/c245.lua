--Evil HERO Malicious Void
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,236,22160245) -- Replace with actual card IDs

    -- Must be Special Summoned with "Dark Fusion"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- Inflict damage if destroys by battle
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(aux.bdgcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)

    -- Change to Attack Position
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCondition(s.poscon)
    e2:SetOperation(s.posop)
    c:RegisterEffect(e2)
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
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        if tc:IsFaceup() then
            Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
        end
    end
end
