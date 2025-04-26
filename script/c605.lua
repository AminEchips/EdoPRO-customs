--Blackwing - Sprint the Typhoon
local s,id=GetID()
s.listed_series={0x33} -- Blackwing archetype
function s.initial_effect(c)
    -- Add 1 Level 4 or higher "Blackwing" monster from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    -- GY effect: Shuffle 3 or 5 "Blackwing" and draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.gycon)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

----------------------------------------------------------
-- Add 1 Level 4+ "Blackwing" monster from Deck
----------------------------------------------------------
function s.thfilter(c)
    return c:IsSetCard(0x33) and c:IsLevelAbove(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- If Normal Summoned, become Tuner
        if c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_ADD_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_TUNER)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end

----------------------------------------------------------
-- Corrected GY Shuffle and Draw
----------------------------------------------------------
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY)
        and Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.gyfilter(c)
    return c:IsSetCard(0x33) and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED))) and c:IsAbleToDeck()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if chk==0 then return g:GetCount()>=3 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local ct=3
    if g:GetCount()>=5 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        ct=5
    end
    local sg=g:Select(tp,ct,ct,nil)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
        local og=Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0 then
            local ct=#g
            if ct==3 then
                Duel.Draw(tp,1,REASON_EFFECT)
            elseif ct==5 then
                Duel.Draw(tp,2,REASON_EFFECT)
            end
        end
    end
end

