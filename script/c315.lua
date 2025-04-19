--Darklord Amesha Spentas
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon procedure
    Link.AddProcedure(c,s.matfilter,2,nil,s.lcheck)
    c:EnableReviveLimit()

    -- Effect 1: Special Summon + banish on link summon with specific materials
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.lkcon)
    e1:SetTarget(s.lktg)
    e1:SetOperation(s.lkop)
    c:RegisterEffect(e1)

    -- Effect 2: Banish 1 to attack again
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Effect 3: If it leaves field by opponent, revive banished Darklord
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0xef}
s.listed_names={316,317} -- Darklord Twin Ark and Covenant

-- Link Summon material filter
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0xef,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsType,1,nil,TYPE_LINK)
end

-- Effect 1: On link summon using both specified cards
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=c:GetMaterial()
    return c:IsSummonType(SUMMON_TYPE_LINK) and mat:IsExists(Card.IsCode,1,nil,316) and mat:IsExists(Card.IsCode,1,nil,317)
end
function s.lkfilter(c,e,tp)
    return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #rg>0 then
            Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        end
    end
end

-- Effect 2: Banish 1 other Darklord to gain extra attack
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupEx(Card.IsSetCard),tp,LOCATION_MZONE,0,1,e:GetHandler(),0xef) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupEx(Card.IsSetCard),tp,LOCATION_MZONE,0,1,1,e:GetHandler(),0xef)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- Effect 3: If it leaves field due to opponent
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return rp~=tp and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
    end
end
