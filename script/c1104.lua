--Salamangreat Emerald Condor
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.EnableCheckReincarnation(c)
    -- Ritual Summon procedure
    aux.AddRitualProcEqual(c, s.ritualfil, nil, nil, nil)

    -- On Special Summon: Add "Rise" + Salamangreat Ritual
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- If Reincarnation Summoned: Send 1 Salamangreat and copy name
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.namecon)
    e2:SetCost(s.namecost)
    e2:SetOperation(s.nameop)
    c:RegisterEffect(e2)
end
s.listed_series={0x119}
s.listed_names={38784726,id}

-- Filter for Ritual Summon with "Rise"
function s.ritualfil(c)
    return c:IsSetCard(0x119)
end

-- Effect 1: Add "Rise" and a Ritual
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.thfilter(c)
    return (c:IsCode(38784726) or (c:IsSetCard(0x119) and c:IsType(TYPE_RITUAL)))
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Effect 2: Reincarnation name change
function s.namecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReincarnationSummoned() and c:IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.costfilter(c)
    return c:IsSetCard(0x119) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetOriginalCode())
    Duel.SendtoGrave(g,REASON_COST)
end

function s.nameop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local code=e:GetLabel()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end
