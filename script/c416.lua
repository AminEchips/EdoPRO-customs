--Starry Knight Sabatiel
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Summon procedure: 1 Level 7 LIGHT Dragon + 1 or more LIGHT Fairy
    Fusion.AddProcMix(c,true,true,s.dragonfilter,s.fairyfilter,1,99)

    -- On Special Summon: Send 1 Level 7 LIGHT Dragon or 1 "Starry Knight" monster from Deck to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- Quick Effect: Target itself, tribute, destroy all, set 1 from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}

-- Fusion Material Filters
function s.dragonfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
end
function s.fairyfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

-- Effect 1: Send to GY on Special Summon
function s.tgfilter(c)
    return (c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT))
        or (c:IsSetCard(0x15b)) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- Effect 2: Tribute self (target), destroy all, then set 1 Starry Knight Continuous S/T from GY
function s.setfilter(c)
    return c:IsSetCard(0x15b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc==e:GetHandler() end
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    Duel.SetTargetCard(e:GetHandler()) -- target self
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.Release(c,REASON_EFFECT) then return end

    -- Destroy all cards on the field
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    -- Select and set 1 "Starry Knight" Continuous S/T from GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 then
        Duel.SSet(tp,sg:GetFirst())
    end

    -- Restrict Special Summoning another Sabatiel this turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsCode(id) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
