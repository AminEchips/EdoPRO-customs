--Abyssal Darklord
local s,id=GetID()
function s.initial_effect(c)
    -- Name becomes "Darklord Morningstar" while on the field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(25451652)
    c:RegisterEffect(e0)

    -- Special Summon from GY if a Darklord is sent
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Quick effect: Reveal hand, pay LP, gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

s.listed_names={25451652}

-- Condition for revive
function s.cfilter(c,tp)
    return c:IsSetCard(0xef) and c:IsControler(tp) and c:IsPreviousControler(tp) and not c:IsSetCode(327) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(-1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- ATK gain effect
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if chk==0 then return #g>0 and Duel.CheckLPCost(tp,#g*200) end
    Duel.ConfirmCards(1-tp,g)
    Duel.PayLPCost(tp,#g*200)
    e:SetLabel(#g)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLP(tp)>=Duel.GetLP(1-tp) then return end
    local c=e:GetHandler()
    local diff=math.floor((Duel.GetLP(1-tp)-Duel.GetLP(tp))/2)
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(diff)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
