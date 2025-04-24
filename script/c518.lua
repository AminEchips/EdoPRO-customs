--Altergeist Lycarope
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    Xyz.AddProcedure(c,nil,3,2)
    c:EnableReviveLimit()

    -- Gains ATK equal to total ATK of attached materials
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Destruction replacement
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(function(e,_c) return s.repfilter(_c,e:GetHandlerPlayer()) end)
    c:RegisterEffect(e2)

    -- Special Summon from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(aux.exccon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x103}

-- Gain ATK equal to sum of attached monsters' original ATK
function s.atkval(e,c)
    local mg=c:GetOverlayGroup()
    local atk=0
    for tc in aux.Next(mg) do
        local a=tc:GetAttack()
        if a>0 then atk=atk+a end
    end
    return atk
end

-- Replace destruction of Altergeist monsters
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x103) and c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
    if Duel.SelectEffectYesNo(tp,c,96) then
        c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
        return true
    else return false end
end

-- Banish 2 "Altergeist" to revive this card
function s.cfilter(c)
    return c:IsSetCard(0x103) and c:IsAbleToRemove()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Banish when leaves field
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end
