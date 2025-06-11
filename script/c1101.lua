--Salamangreat Pheasant
local s,id=GetID()
function s.initial_effect(c)
    --List archetype
    s.listed_series={0x119}

    --Special Summon from hand, boost target
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --On Special Summon: reveal to change name
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.namecost)
    e2:SetOperation(s.nameop)
    c:RegisterEffect(e2)
end

-- Effect 1: Target Link monster and summon self
function s.linkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.linkfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingTarget(s.linkfilter,tp,LOCATION_MZONE,0,1,nil)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.linkfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
        and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(800)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- Effect 2: Reveal as cost, change name
function s.namecostfilter(c)
    return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.namecostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.namecostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
    e:SetLabelObject(g:GetFirst())
    Duel.ConfirmCards(1-tp,g)
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=e:GetLabelObject()
    if not c:IsRelateToEffect(e) or not rc then return end
    local code=rc:GetOriginalCode()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end
