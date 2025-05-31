--Raidraptor - Golden Strix
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Summon procedure
    Pendulum.AddProcedure(c)

    --Pendulum Effect: Redirect attack to this card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    --Monster Effect: Special Summon itself from hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Monster Effect: Move to Pendulum Zone if destroyed or sent to GY as cost for DARK monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.pzcon)
    e3:SetTarget(s.pztg)
    e3:SetOperation(s.pzop)
    c:RegisterEffect(e3)
end
s.listed_series={0xba} -- Raidraptor

--🔷 Effect 1: Redirect attack to this card
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local d=Duel.GetAttackTarget()
    return d and d:IsControler(tp) and d:IsRace(RACE_WINGEDBEAST) and d:IsType(TYPE_XYZ)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local d=Duel.GetAttackTarget()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and d then
        Duel.ChangeAttackTarget(c)
    end
end

--🔶 Effect 2: Special Summon condition
function s.onlydarkwinged(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WINGEDBEAST)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return #g==0 or g:FilterCount(s.onlydarkwinged,nil)==#g
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--🔶 Effect 3: Move to Pendulum Zone
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (
        c:IsReason(REASON_DESTROY) or
        ((r & REASON_COST) ~= 0 and re and re:IsActivated() and re:GetHandler():IsAttribute(ATTRIBUTE_DARK))
    ) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
    end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
