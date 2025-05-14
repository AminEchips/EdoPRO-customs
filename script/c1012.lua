--Despian Dragon King
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials
    Fusion.AddProcMix(c,true,true,68468459,s.matfilter)

    -- Copy End Phase effect from Albaz Fusion
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.copetg)
    e1:SetOperation(s.copeop)
    c:RegisterEffect(e1)

    -- Destruction effect if Fusion leaves due to opponent
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desreg)
    c:RegisterEffect(e2)
end
s.listed_names={68468459}
s.listed_series={0x16f} -- If needed for Despia

-- Material filter: Must mention "Fallen of Albaz"
function s.matfilter(c,scard,sumtype,tp)
    return c:IsType(TYPE_FUSION) and c:ListsCode(68468459)
end

-- e1: Copy effect targeting Fusion in GY
function s.copfilter(c)
    return c:IsType(TYPE_FUSION) and c:ListsCode(68468459) and not c:IsCode(id)
        and c:IsAbleToExtra()
end
function s.copetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.copfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.copfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.copeop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end

    local code=tc:GetOriginalCodeRule()
    local te=Duel.GetCardEffect(tc,EVENT_PHASE+PHASE_END)
    if not te then return end

    local op=te:GetOperation()
    local tg=te:GetTarget()
    local cat=te:GetCategory()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(cat)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    if tg then
        e1:SetTarget(tg)
    end
    e1:SetOperation(op)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
end

-- e2: Register Fusion that left due to opponent’s effect
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c)
        return c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION)
            and c:IsPreviousControler(tp)
            and c:IsReason(REASON_EFFECT) and rp==1-tp
    end,1,nil)
end
function s.desreg(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id+100)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
    Duel.Destroy(g,REASON_EFFECT)
end
