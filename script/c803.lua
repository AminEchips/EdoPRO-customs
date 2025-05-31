--Raidraptor - Scavenger Lanius
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Special Summon 1 Level 6 DARK from hand or GY during summon turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.sscon)
    e1:SetOperation(s.ssop)
    c:RegisterEffect(e1)

    -- Register summon flag for this turn
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SUMMON_SUCCESS)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)
    local e0b=e0:Clone()
    e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e0b)

    -- Effect 2: GY effect - Add Rank-Up-Magic Spell sent this turn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.rumcost)
    e2:SetOperation(s.rumop)
    c:RegisterEffect(e2)
end
s.listed_series={0xba,0x10db,0x95} -- Raidraptor, The Phantom Knights, Rank-Up-Magic

-- Summon flag registration
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

-- Effect 1: Can activate if summoned this turn
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
function s.ssfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        if c:IsFaceup() and tc:IsFaceup() and c:IsCode(id) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            for _,mc in ipairs({c,tc}) do
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LEVEL)
                e1:SetValue(1)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                mc:RegisterEffect(e1)
            end
        end
    end
end

-- Effect 2: GY cost filter (The Phantom Knights)
function s.rumcostfilter1(c)
    return c:IsAbleToRemoveAsCost() and c:IsSetCard(0xba)
end
function s.rumcostfilter2(c)
    return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x10db)
end
function s.rumcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToRemoveAsCost()
            and Duel.IsExistingMatchingCard(s.rumcostfilter1,tp,LOCATION_GRAVE,0,1,c)
            and Duel.IsExistingMatchingCard(s.rumcostfilter2,tp,LOCATION_GRAVE,0,1,c)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.rumcostfilter1,tp,LOCATION_GRAVE,0,1,1,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.rumcostfilter2,tp,LOCATION_GRAVE,0,1,1,c)
    g1:AddCard(c)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

-- Filter: Rank-Up-Magic Spell sent this turn
function s.rumfilter(c)
    return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL)
        and c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE)
        and c:IsReason(REASON_EFFECT+REASON_COST+REASON_RULE)
        and c:GetTurnID()==Duel.GetTurnCount()
end
function s.rumop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.rumfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
