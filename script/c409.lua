--Starry Knight Armored Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,function(c)return c:IsSetCard(0x15b)end,4,2)
    c:EnableReviveLimit()

    --Detach up to 2 to search that many "Starry Knight" Spell/Traps
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    --Tribute to Summon a Level 7 LIGHT Dragon from GY to hand and Special Summon it
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x15b}

-- e1: Search Starry Knight Spell/Traps
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetOverlayCount()
    if chk==0 then return ct>0 end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local num=Duel.AnnounceNumber(tp,1,2)
    c:RemoveOverlayCard(tp,num,num,REASON_COST)
    e:SetLabel(num)
end
function s.filter(c)
    return c:IsSetCard(0x15b) and (c:IsSpell() or c:IsTrap()) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel(),tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,ct,ct,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- e2: Tribute to summon Level 7 LIGHT Dragon from GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsLevel(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
