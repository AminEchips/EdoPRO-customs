--Blackwing - Puelche the Blazing
local s,id=GetID()
s.listed_series={SET_BLACKWING,0x33,0x1033}
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Banish self if it leaves the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCondition(function(e) return true end)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1)
    -- Destruction replacement
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
    -- Special Summon Assault Blackwing + Level reduce + make Tuner
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

----------------------------------------------------------
-- (2) Destruction replacement
----------------------------------------------------------
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x33) and c:IsAttackPos()
        and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsOnField()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.repfilter,nil,tp)
    if chk==0 then return #g>0 end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    else
        return false
    end
end
function s.repval(e,c)
    return s.repfilter(c,c:GetControler())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    for tc in aux.Next(g) do
        if tc:IsRelateToBattle() or tc:IsRelateToEffect(e) then
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
        end
    end
    g:DeleteGroup()
end

----------------------------------------------------------
-- (3) Special Summon Assault Blackwing + Level adjust + make Tuner
----------------------------------------------------------
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1033) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        -- Reduce this card's Level
        local lv=tc:GetOriginalLevel()
        if lv>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetValue(-lv)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
        -- Optionally make the monster a Tuner
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            local e2=Effect.CreateEffect(tc)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_ADD_TYPE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetValue(TYPE_TUNER)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end
