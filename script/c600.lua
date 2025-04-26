--Assault Blackwing - Artemis the Bolt
local s,id=GetID()
function s.initial_effect(c)
    -- Can be Special Summoned from GY by tributing 1 "Blackwing" monster (not treated as an effect)
    aux.EnableUnsummonable(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_GRAVE)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    -- If Special Summoned this way, become a Tuner
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_MZONE) end)
    e1:SetOperation(s.tunerop)
    c:RegisterEffect(e1)

    -- Quick effect: Negate + Double ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end
s.listed_series={0x33,0x1033}
s.listed_names={9012916} -- Black-Winged Dragon

------------------------
-- Special Summon logic
------------------------
function s.spfilter(c)
    return c:IsSetCard(0x33) and c:IsReleasable()
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.CheckReleaseGroup(c:GetControler(),s.spfilter,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.spfilter,1,1,nil)
    Duel.Release(g,REASON_COST)
end

-- Become Tuner after being Special Summoned
function s.tunerop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetValue(TYPE_TUNER)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end

------------------------
-- Quick Negate Effect
------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_DAMAGE and not Duel.IsDamageCalculated()
        and re:IsActivated()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsChainDisablable(ev) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local bc=Duel.GetAttacker()
        if bc and bc:IsControler(tp) and (bc:IsSetCard(0x33) or bc:IsCode(9012916)) and bc:IsFaceup() and bc:IsRelateToBattle() then
            local atk=bc:GetAttack()
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            bc:RegisterEffect(e1)
        end
    end
end

