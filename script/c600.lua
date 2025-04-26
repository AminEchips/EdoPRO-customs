--Assault Blackwing - Artemis the Bolt
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from GY by tributing 1 "Blackwing" monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Quick Effect: Send self to GY to negate and double ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end
s.listed_series={0x33,0x1033}
s.listed_names={9012916} -- Black-Winged Dragon

----------------------------------------------------------
-- Special Summon Procedure
----------------------------------------------------------
function s.spfilter(c)
    return c:IsSetCard(0x33) and c:IsReleasable()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.CheckReleaseGroup(tp,s.spfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.spfilter,1,1,false,true,true,c,nil,nil,false,nil)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if g then
        Duel.Release(g,REASON_COST)
        g:DeleteGroup()

        -- Become Tuner
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_TUNER)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
        c:RegisterEffect(e1)
    end
end

----------------------------------------------------------
-- Negate + Double ATK Effect
----------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase() and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        -- If you control a battling Blackwing or Black-Winged Dragon, double its ATK
        local bc=Duel.GetAttacker()
        if not bc then bc=Duel.GetAttackTarget() end
        if bc and bc:IsFaceup() and (bc:IsSetCard(0x33) or bc:IsCode(9012916)) then
            local atk=bc:GetAttack()
            if atk>0 then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(atk)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                bc:RegisterEffect(e1)
            end
        end
    end
end




