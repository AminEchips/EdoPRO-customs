--Crystafrost the Weapon Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials
    Fusion.AddProcMix(c,true,true,68468459,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA)) -- Albaz + Aqua

    -- Destruction protection once per turn
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCountLimit(1)
    e0:SetValue(s.indct)
    c:RegisterEffect(e0)

    -- On Fusion Summon: Special Summon 1 Tuner from either GY to either field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(s.tunertg)
    e1:SetOperation(s.tunerop)
    c:RegisterEffect(e1)

    -- Register GY trigger for End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
end
s.listed_names={68468459}
s.listed_series={0x16e} -- Icejade

-- Protection once per turn from destruction
function s.indct(e,re,r,rp)
    return (r&REASON_BATTLE+REASON_EFFECT)~=0
end

-- Tuner from either GY
function s.tunerfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tunertg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
function s.tunerop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    local summon_tp=tp
    if tc:IsControler(1-tp) then
        -- Allow summon to opponent’s field
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            summon_tp=1-tp
        end
    end
    Duel.SpecialSummon(tc,0,tp,summon_tp,false,false,POS_FACEUP)
end

-- GY → End Phase: Add or Special Summon Icejade or Albaz
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id+100)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end
function s.thfilter(c,e,tp,ft)
    return c:IsMonster() and (c:IsSetCard(0x16e) or c:IsCode(68468459))
        and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
    local tc=g:GetFirst()
    if tc then
        aux.ToHandOrElse(tc,tp,
            function(c) return ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
            function(c) Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end,
            aux.Stringid(id,3))
    end
end
