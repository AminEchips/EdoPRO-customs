--Starry Knight Distortion
local s,id=GetID()
function s.initial_effect(c)
    -- Activate effect: Optional Special Summon from hand or GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Main Phase Effect: Set 1 "Starry Knight" S/T or reset this card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

function s.filter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.setfilter(c)
    return c:IsSetCard(0x15b) and c:IsSpellTrap() and not c:IsCode(id) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
        or e:GetHandler():IsSSetable() end
    local b1=Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
    local b2=e:GetHandler():IsSSetable()
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        Duel.SelectOption(tp,aux.Stringid(id,1))
        op=0
    else
        Duel.SelectOption(tp,aux.Stringid(id,2))
        op=1
    end
    e:SetLabel(op)
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
    end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            Duel.SSet(tp,tc)
        end
    else
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsSSetable() then
            Duel.ChangePosition(c,POS_FACEDOWN)
            Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
        end
    end
end
