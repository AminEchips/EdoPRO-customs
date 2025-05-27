--Odd-Eyes Continuum Gazing Magician of Time and Space
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Attribute
    Pendulum.AddProcedure(c)

    --Pendulum Effect: Damage based on attacks
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

    --Negate and optionally destroy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    --Battle destroy: Revive and inflict damage
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(aux.bdocon)
    e4:SetTarget(s.btg)
    e4:SetOperation(s.bop)
    c:RegisterEffect(e4)

    --When destroyed: place to Pendulum Zone and recover
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id+300)
    e5:SetTarget(s.pztg)
    e5:SetOperation(s.pzop)
    c:RegisterEffect(e5)
end

--Filters
function s.oddEyesFilter(c)
    return c:IsSetCard(0x99)
end
function s.magicianFilter1(c)
    return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
function s.magicianFilter2(c)
    return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end

--Pendulum damage condition
function s.pdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_PENDULUM) and c:IsStatus(STATUS_BATTLE_DESTROYED) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.pdop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetAttackCount()
    if ct>0 then
        Duel.Damage(1-tp,ct*600,REASON_EFFECT)
    end
end

--LP gain Quick Effect
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Destroy(c,REASON_EFFECT)>0 then
        Duel.Recover(tp,1200,REASON_EFFECT)
    end
end

--Negate Target
function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
    e:SetLabelObject(g)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    for tc in g:Iter() do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
            tc:RegisterEffect(e1)
        end
    end
end

--Battle destroy: revive and burn
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_PENDULUM),tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Damage(1-tp,sc:GetAttack(),REASON_EFFECT)
        end
    end
end

--Destroyed effect
function s.pzfilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)~=0 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)~=0 then
            if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil)
                and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
                if #g2>0 then
                    Duel.SendtoHand(g2,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,g2)
                end
            end
        end
    end
end
