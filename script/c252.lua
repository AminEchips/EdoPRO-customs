--Evil Backlash
local s,id=GetID()
function s.initial_effect(c)
    --Field Effect: Return Fusion, revive materials
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --GY Effect: Gain ATK on attack
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100,EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

s.listed_names={94820406} -- Dark Fusion

function s.matfilter(c)
    return c:IsMonster() and c:IsAbleToSpecialSummon()
end

function s.fusionfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsAbleToRemove()
        and c:IsSummonType(SUMMON_TYPE_FUSION)
        and c:GetMaterialCount()>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.fusionfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.fusionfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.fusionfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local mat=tc:GetMaterial()
    if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and #mat>0 then
        local sg=mat:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
        if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#sg then
            Duel.BreakEffect()
            for sc in aux.Next(sg) do
                Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
            end
            Duel.SpecialSummonComplete()
        end
    end
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x6008)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
    -- Only gain ATK during damage calculation if attacking
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(2100)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetCondition(s.atkcon)
    e1:SetLabelObject(tc)
    tc:RegisterEffect(e1)
end

function s.atkcon(e)
    local c=e:GetHandler()
    return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttacker()==c
end


