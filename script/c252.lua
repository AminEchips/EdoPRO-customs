--Evil Backlash
local s,id=GetID()
function s.initial_effect(c)
    -- Banish 1 Fusion, then revive materials
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    -- GY ATK boost effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

s.listed_names={94820406}
s.listed_series={0x6008}

function s.matfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION)
        and c:GetMaterialCount()>0 and c:IsAbleToRemove()
        and c:IsSummonLocation(LOCATION_EXTRA)
        and c:GetReasonEffect() and c:GetReasonEffect():GetHandler():IsCode(94820406)
        and c:GetMaterial():FilterCount(aux.NecroValleyFilter(s.matfilter),nil,e,tp)==c:GetMaterialCount()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,g:GetFirst():GetMaterialCount(),tp,LOCATION_GRAVE)
    e:SetLabelObject(g:GetFirst())
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local fc=e:GetLabelObject()
    if fc and fc:IsRelateToEffect(e) and Duel.Remove(fc,POS_FACEUP,REASON_EFFECT)>0 then
        local mg=fc:GetMaterial():Filter(aux.NecroValleyFilter(s.matfilter),nil,e,tp)
        if #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#mg then
            Duel.BreakEffect()
            Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsSetCard(0x6008) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,0x6008),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,0x6008),tp,LOCATION_MZONE,0,1,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(2100)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    tc:RegisterEffect(e1)
end
