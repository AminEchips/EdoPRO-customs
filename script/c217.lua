--Elemental HERO Surge Breaker
local s,id=GetID()
function s.initial_effect(c)
    -- Must be Fusion Summoned
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,21844576,20721928,86188410) -- Avian, Sparkman, Wildheart

    -- On Special Summon: Add 1 "O - Oversoul"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Tribute this card to SS Elemental HERO Normal & attack lock
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_names={63703130,22020907} -- O - Oversoul, Hero Flash!!
s.material_setcode=0x3008

-- Condition: Only trigger if Fusion Summoned
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Add Oversoul, then check for 3+ non-Poly/Fusion Spells and add Hero Flash!!
function s.thfilter1(c)
    return c:IsCode(63703130) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_NORMAL) and not c:IsSetCard(0x46)
        and c:IsAbleToHand()
end
function s.heroFlash(c)
    return c:IsCode(22020907) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)

        local gy=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_GRAVE,0,nil)
        local names={}
        for tc in aux.Next(gy) do
            local code=tc:GetCode()
            names[code]=true
        end
        local count=0
        for _ in pairs(names) do count = count + 1 end

        if count>=3 and Duel.IsExistingMatchingCard(s.heroFlash,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=Duel.SelectMatchingCard(tp,s.heroFlash,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
    end
end

-- Cost: Tribute self
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Target 1 E-HERO Normal in GY
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        -- Opponent cannot activate cards/effects when your monsters attack directly this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetValue(s.aclimit)
        e1:SetCondition(s.actcon)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.aclimit(e,re,tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
    local at=Duel.GetAttacker()
    return at and at:IsControler(e:GetHandlerPlayer()) and at:IsDirectAttacker()
end

