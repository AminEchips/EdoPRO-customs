-- HERO Second Signal
local s,id=GetID()
function s.initial_effect(c)
    -- Activate one of the three effects
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Set itself from GY by banishing another card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- Fusion filter
function s.fusfilter(c,e,tp,mg,chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,chkf)
end

-- HERO destroyed filter
function s.hfilter(c,tp)
    return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0x8)
end

-- Match-Level HERO summonable from anywhere
function s.hspfilter(c,lv,e,tp)
    return c:IsSetCard(0x8) and c:IsLevel(lv)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Targeting menu
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local chkf=tp
    local b1=false
    local b2=false
    local mg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_DECK,0,nil)
    if Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf) then b1=true end
    if Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
        and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,0x8) then b2=true end

    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,0))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    end
end

-- Activate one of the two effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        local chkf=tp
        local mg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_DECK,0,nil)
        local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
        if #sg==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=sg:Select(tp,1,1,nil):GetFirst()
        if not tc then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
        if not mat or #mat==0 then return end
        tc:SetMaterial(mat)
        Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    else
        local g=Duel.GetMatchingGroup(s.hfilter,tp,LOCATION_GRAVE,0,nil,tp)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local dg=g:Select(tp,1,1,nil)
        local lv=dg:GetFirst():GetLevel()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- GY Set effect
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SSet(tp,c)
    end
end
