--Raidraptor's Rank Trap
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be negated if 3+ Raidraptor Xyz in GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_INACTIVATE)
    e0:SetCondition(s.chainlim)
    c:RegisterEffect(e0)
    local e0b=e0:Clone()
    e0b:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e0b)

    -- Activate: negate attack and revive, then optional Rank-Up
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Check for 3+ Raidraptor Xyz in GY
function s.rrxyzfilter(c)
    return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
function s.chainlim(e)
    return Duel.GetMatchingGroupCount(s.rrxyzfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3
end

-- Trigger: opponent's direct attack
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    return Duel.GetAttackTarget()==nil and at:IsControler(1-tp)
end

-- Valid Raidraptor Xyz in GY
function s.filter(c,e,tp)
    return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.rkupfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

-- Rank-Up target: 2 Ranks higher Xyz
function s.rkupfilter(c,e,tp,mc)
    return c:IsType(TYPE_XYZ) and c:GetRank()==mc:GetRank()+2
        and mc:IsCanBeXyzMaterial(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end

-- Activate: negate attack → revive → optional Rank-Up
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateAttack() then
        local c=e:GetHandler()
        local tc=Duel.GetFirstTarget()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE) then
            Duel.BreakEffect()
            if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local g=Duel.SelectMatchingCard(tp,s.rkupfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
                local sc=g:GetFirst()
                if sc then
                    local mg=tc:GetOverlayGroup()
                    sc:SetMaterial(Group.FromCards(tc))
                    Duel.Overlay(sc,mg)
                    Duel.Overlay(sc,Group.FromCards(tc))
                    Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
                    sc:CompleteProcedure()
                end
            end
        end
    end
end
