--Starry Knight's Wyvern
local s,id=GetID()
function s.initial_effect(c)
    --Effect 1: Quick Effect in hand to bounce a Starry Knight card you control, then Special Summon this
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Effect 2: Bounce this and one opponent's Special Summoned monster (no targeting)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.bouncecon)
    e2:SetCost(s.bouncecost)
    e2:SetOperation(s.bounceop)
    c:RegisterEffect(e2)
    
end

s.listed_series={0x15b}

-- Effect 1: Special Summon from hand by bouncing a Starry Knight card you control
function s.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x15b) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Check if opponent Special Summoned at least 1 monster
function s.bouncecon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

-- Return this card to the hand as cost
function s.bouncecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHandAsCost() end
    Duel.SendtoHand(c,nil,REASON_COST)
end

function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    local og=g:Filter(function(c)
        return c:IsControler(1-tp) and c:IsRelateToEffect(e) and c:IsAbleToHand()
    end,nil)
    if #og>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg=og:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
    end
end

