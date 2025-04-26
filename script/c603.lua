--Blackwing - Raze the Orographic Lift
local s,id=GetID()
s.listed_series={0x33} -- Blackwing archetype
function s.initial_effect(c)
    -- Special Summon itself from hand without activating
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    c:RegisterEffect(e1)
    -- Decrease Level on Normal or Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

----------------------------------------------------------
-- Special Summon Procedure
----------------------------------------------------------
function s.spfilter(c)
    return c:IsSetCard(0x33) and not c:IsCode(id)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    -- No cost needed, just fulfill condition
end

----------------------------------------------------------
-- Decrease Level Effect
----------------------------------------------------------
function s.lvfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(id)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
        local lv=tc:GetLevel()
        if lv>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetValue(-lv)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end
