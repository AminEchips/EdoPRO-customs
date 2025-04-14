--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand and place into the Spell/Trap Zone as a Continuous Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Effect 1: Send 1 Fusion Monster to the GY, and Special Summon 1 "Neo-Spacian" monster from your GY with the same Attribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)  -- Activated from Spell/Trap Zone
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.target1)
    e2:SetOperation(s.operation1)
    c:RegisterEffect(e2)

    -- Effect 2: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    c:RegisterEffect(e3)

    -- Effect 3: During the End Phase, place "Neo Space" (code: 42015635) from your Deck or GY into the Field Zone
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOFIELD)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.target3)
    e4:SetOperation(s.operation3)
    c:RegisterEffect(e4)
end

-- Effect 1: Send Fusion Monster to GY and Special Summon Neo-Spacian
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFusionSummonable,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(function(c)
                return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToHand() end,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    -- Send a Fusion Monster to GY and Special Summon a Neo-Spacian from GY with the same Attribute
    local tg=Duel.SelectMatchingCard(tp,Card.IsFusionSummonable,tp,LOCATION_GRAVE,0,1,1,nil)
    if #tg>0 then
        Duel.SendtoGrave(tg,REASON_EFFECT)
        local special=Duel.SelectMatchingCard(tp,aux.FilterBoolFunction(Card.IsSetCard,0x8),tp,LOCATION_GRAVE,0,1,1,nil)
        if #special>0 then
            Duel.SpecialSummon(special,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Effect 2: Shuffle Fusion Monsters related to "Elemental HERO Neos" into the Extra Deck
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check for Fusion Monsters that mention "Elemental HERO Neos" in the GY
        return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    -- Shuffle Fusion Monsters that mention "Elemental HERO Neos" into the Extra Deck
    local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
end

-- Effect 3: Place "Neo Space" from Deck or GY into the Field Zone
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check if "Neo Space" (code: 42015635) is in the Deck or GY
        return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,42015635)  -- Neo Space's code
    end
    Duel.SetOperationInfo(0,CATEGORY_TOFIELD,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.operation3(e,tp,eg,ep,ev,re,r,rp)
    -- Place "Neo Space" into the Field Zone from Deck or GY
    local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,42015635) -- Neo Space's code
    if #g>0 then
        -- Move Neo Space to the Field Zone as a Field Spell
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end
