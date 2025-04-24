--Altergeist Jenitama
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Ritual Summon using "Altergeist Formatting"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e0:SetCondition(s.ritcon)
    e0:SetOperation(s.ritop)
    c:RegisterEffect(e0)

    -- Gains 1000 ATK during turn a Trap was activated
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(1000)
    c:RegisterEffect(e1)

    -- Inflict 1000 damage when a Trap is activated (except during Damage Step)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.damcon)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    -- Float: Special Summon 1 "Altergeist" Extra Deck monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x103}

-- RITUAL SUMMON CONDITIONS (manual)
function s.matfilter(c)
    return c:IsReleasable() and (c:IsLevelAbove(1) or c:IsType(TYPE_LINK))
end
function s.getLevelValue(c)
    return c:IsType(TYPE_LINK) and c:GetLink() or c:GetLevel()
end
function s.ritcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:CheckWithSumGreater(s.getLevelValue,c:GetLevel(),c)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local mat=mg:SelectWithSumGreater(tp,s.getLevelValue,c:GetLevel(),c)
    c:SetMaterial(mat)
    Duel.Release(mat,REASON_COST+REASON_MATERIAL)
end

-- Trap activation flag
function s.atkcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

-- Trap Activation Damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_TRAP) and not (Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,1000,REASON_EFFECT)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- Floating Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x103) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
