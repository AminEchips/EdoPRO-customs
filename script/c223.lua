--Elemental HERO Chaos Avenger
local s,id=GetID()
function s.initial_effect(c)
    --Must be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,2)

    --Treat as DARK on field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e0)

    --Send 1 E-HERO with ≥ ATK from Deck/Extra to GY, then flip target face-down
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.potg)
    e1:SetOperation(s.poop)
    c:RegisterEffect(e1)

    --Tribute to Special Summon from banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series={0x3008}
s.material_setcode={0x3008}

function s.matfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x3008,fc,sumtype,tp) and c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

-- Flip face-down effect
function s.pofilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.gyfilter(c,atk)
    return c:IsSetCard(0x3008) and (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_EXTRA))
        and c:IsType(TYPE_MONSTER) and c:IsAttackAbove(atk) and c:IsAbleToGrave()
end
function s.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.pofilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.pofilter,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,0) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.pofilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.poop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local atk=tc:GetAttack()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,atk)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end

-- Special Summon during End Phase
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x3008) and not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
