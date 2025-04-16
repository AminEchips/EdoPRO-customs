--Elemental HERO Omniverse
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.fusfilter1,s.fusfilter2,s.fusfilter3,s.fusfilter4)

    -- Shuffle 1 and burn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.shufcon)
    e1:SetTarget(s.shuftg)
    e1:SetOperation(s.shufop)
    c:RegisterEffect(e1)

    -- Special Summon 1 Elemental HERO from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Gain ATK when attacking
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

s.material_setcode={0x3008}

-- Fusion materials: 4 Elemental HERO Fusion Monsters with different attributes
function s.fusfilter1(c,scard,sumtype,tp) return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_WIND,scard,sumtype,tp) end
function s.fusfilter2(c,scard,sumtype,tp) return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp) end
function s.fusfilter3(c,scard,sumtype,tp) return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE,scard,sumtype,tp) end
function s.fusfilter4(c,scard,sumtype,tp) return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_EARTH,scard,sumtype,tp) end

-- Shuffle & Burn Effect
function s.shufcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler()) or eg:IsExists(s.attrdiff,1,nil,tp)
end
function s.attrdiff(c,tp)
    return c:IsControler(1-tp) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
function s.shuftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.shufop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        local tc=g:GetFirst()
        if tc:IsPreviousTypeOnField(TYPE_MONSTER) and tc:GetBaseAttack()>0 then
            Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
        end
    end
end

-- GY revive effect (now targets)
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ATK Gain effect
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,99,nil)
    if #g>0 then
        if Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(#g*1000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end
