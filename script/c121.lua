--Odd-Eyes Continuum Gazing Magician of Time and Space
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Attribute
    Pendulum.AddProcedure(c)

    --Pendulum Effect: Damage based on attacks declared
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

    --Pendulum Effect: Quick LP gain
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)

    --Fusion Summon procedure
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.oddEyesFilter,s.magicianFilter1,s.magicianFilter2)

    --Negate up to 3 face-up cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    --Battle destroy: revive Pendulum and burn
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(aux.bdocon)
    e4:SetTarget(s.btg)
    e4:SetOperation(s.bop)
    c:RegisterEffect(e4)

    --Floating effect: revive Pendulum Zone card, enter PZone, optionally recover
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e5:SetCountLimit(1,id+300)
    e5:SetTarget(s.pztg)
    e5:SetOperation(s.pzop)
    c:RegisterEffect(e5)

    -- Global check: count attacks declared this turn
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

-- Pendulum Effect: damage
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

-- LP gain
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Destroy(c,REASON_EFFECT)>0 then
        Duel.Recover(tp,1200,REASON_EFFECT)
    end
end

-- Negate up to 3 face-up cards
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
    g:KeepAlive()
    e:SetLabelObject(g)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    for tc in aux.Next(g) do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
            tc:RegisterEffect(e1)
        end
    end
    g:DeleteGroup()
end

-- Revive on battle destroy
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Damage(1-tp,sc:GetAttack(),REASON_EFFECT)
        end
    end
end

-- Float on destroy
function s.pzfilter(c)
    return c:IsFaceup() and c:IsLocation(LOCATION_PZONE) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.pzfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.pzfilter,tp,LOCATION_PZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    Duel.SelectTarget(tp,s.pzfilter,tp,LOCATION_PZONE,0,1,1,nil)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)>0 then
            if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil)
                and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
                if #g>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,g)
                end
            end
        end
    end
end
