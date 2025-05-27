--Odd-Eyes Continuum Gazing Magician of Time and Space
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- Pendulum Effect: Burn based on attacks
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DAMAGE_STEP_END)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.pdcon)
    e1:SetOperation(s.pdop)
    c:RegisterEffect(e1)

    -- Pendulum Effect: Quick LP gain
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)

    -- Fusion procedure
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.oddEyesFilter,s.magicianFilter1,s.magicianFilter2)

    -- Negate and optionally destroy (properly targets & resets on YOUR Standby Phase)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- Battle destroy: revive Pendulum and burn
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(aux.bdocon)
    e4:SetTarget(s.btg)
    e4:SetOperation(s.bop)
    c:RegisterEffect(e4)

    -- Float on destruction
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id+300)
    e5:SetCondition(s.pencon)
    e5:SetTarget(s.pentg)
    e5:SetOperation(s.penop)
    c:RegisterEffect(e5)

    -- Global: Count attacks
    if not s.global_check then
        s.global_check=true
        s.attack_count=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
        ge1:SetOperation(function() s.attack_count=s.attack_count+1 end)
        Duel.RegisterEffect(ge1,0)

        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        ge2:SetOperation(function() s.attack_count=0 end)
        Duel.RegisterEffect(ge2,0)
    end
end

-- Fusion filters
function s.oddEyesFilter(c)
    return c:IsSetCard(0x99)
end
function s.magicianFilter1(c)
    return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
function s.magicianFilter2(c)
    return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end

-- Pendulum burn effect
function s.pdcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return (a and a:IsControler(tp) and a:IsType(TYPE_PENDULUM)) or (d and d:IsControler(tp) and d:IsType(TYPE_PENDULUM))
end
function s.pdop(e,tp,eg,ep,ev,re,r,rp)
    if s.attack_count>0 then
        Duel.Damage(1-tp,s.attack_count*600,REASON_EFFECT)
    end
end

-- LP recovery
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Destroy(c,REASON_EFFECT)>0 then
        Duel.Recover(tp,1200,REASON_EFFECT)
    end
end

-- Negate and optional destroy
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    for tc in aux.Next(tg) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
        end
    end
    if Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
        local dg=tg:Filter(Card.IsRelateToEffect,nil,e)
        Duel.Destroy(dg,REASON_EFFECT)
    end
end

-- Battle destroy: revive from GY/banished/PZ only
function s.bfilter(c,e,tp)
    return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_PZONE,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Damage(1-tp,sc:GetAttack(),REASON_EFFECT)
    end
end

-- Float into PZone + optional recover from GY
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup()
end
function s.penfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
            if Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,nil)>0
                and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
                if #sg>0 then
                    Duel.SendtoHand(sg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,sg)
                end
            end
        end
    end
end
