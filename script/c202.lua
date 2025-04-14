
--Favorite Fusion
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and Fusion Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)

    -- GY effect: Banish to recycle 3 "HERO" Fusion Monsters and draw 1
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

-- Fusion Summon
function s.filter(c,e,tp,m,chkf)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(m,nil,chkf)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg1=Duel.GetFusionMaterial(tp)
        local mg2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK,0,nil)
        mg1:Merge(mg2)
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,chkf)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp)

    -- Check if a "Wingman" is being summoned for Deck access
    local mg2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK,0,nil)
    mg1:Merge(mg2)

    local sg=Duel.GetMatchingGroup(function(c)
        return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
            and c:CheckFusionMaterial(mg1,nil,chkf)
    end,tp,LOCATION_EXTRA,0,nil)

    if #sg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=sg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end

    local deckFusion = tc:IsCode("56733747") or tc:IsCode(35809262) or tc:IsCode(93347961) or tc:IsCode(25366484) or tc:IsCode(160020065) or tc:IsCode(160320002)
    local matGroup = Duel.GetFusionMaterial(tp)

    if deckFusion then
        matGroup:Merge(Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK,0,nil))
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local mat=Duel.SelectFusionMaterial(tp,tc,matGroup,nil,chkf)
    if not mat or #mat==0 then return end

    tc:SetMaterial(mat)
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    tc:CompleteProcedure()
end

-- GY effect: Recycle and draw
function s.tdfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
    if #g==3 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
