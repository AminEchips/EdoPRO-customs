-- HERO Second Signal
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Fusion Summon using HERO monsters in hand/field, shuffled into Deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)

    -- Trigger: When a HERO is destroyed, summon a HERO with the same Level
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- GY Effect: Set this card if any monster is destroyed by battle; banish on leave
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end

-- Fusion Summon using HERO monsters from hand/field
function s.fusfilter(c,e,tp,mg,chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,chkf)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    local chkf=tp
    local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToDeck,nil)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToDeck,nil)
    local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
    if #sg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=sg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
    if #mat==0 then return end
    tc:SetMaterial(mat)
    Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    tc:CompleteProcedure()
end

-- HERO destroyed trigger
function s.spfilter(c,tp)
    return c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.spfilter,nil,tp)
    if chk==0 then
        return #g>0 and Duel.IsExistingMatchingCard(function(c)
            return c:IsSetCard(0x8) and c:IsLevel(g:GetFirst():GetLevel())
                and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.spfilter,nil,tp)
    if #g==0 then return end
    local lv=g:GetFirst():GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,function(c)
        return c:IsSetCard(0x8) and c:IsLevel(lv)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- GY: set if any monster destroyed by battle
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SSet(tp,c)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end
