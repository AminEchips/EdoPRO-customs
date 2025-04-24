--Altergeist Flawpharite
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Link Summon requirement: 1 non-Link "Altergeist" monster
    Link.AddProcedure(c,s.matfilter,1,1)

    -- On Link Summon: Add "Personal Spoofing" or 1 "Altergeist" Continuous Trap
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Once per Duel: You can activate "Spoofing" or an "Altergeist" Continuous Trap the turn it is Set
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetTarget(s.actfilter)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)
end

s.listed_series={0x103}

-- Material requirement
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x103,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end

-- Effect 1: Add to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
    return (c:IsCode(53936268) or (c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)))
        and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Effect 2: Can activate Set Altergeist Continuous Trap or Spoofing this turn
function s.actfilter(e,c)
    return (c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)) or c:IsCode(53936268)
end
