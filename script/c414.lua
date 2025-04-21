--Starry Knight Distortion
local s,id=GetID()
function s.initial_effect(c)
    --Activate: Optional Special Summon 1 LIGHT monster from hand or 1 "Starry Knight" from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --Main Phase Choice: Set another "Starry Knight" S/T from GY or Set itself face-down
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}

function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x15b)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Set 1 "Starry Knight" Spell/Trap from GY or Set this card face-down
function s.setfilter(c)
    return c:IsSetCard(0x15b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
    local b1=Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
    local b2=e:GetHandler():IsSSetable()
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,3))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
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
    elseif op==1 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsSSetable() then
            Duel.ChangePosition(c,POS_FACEDOWN)
            Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
        end
    end
end
