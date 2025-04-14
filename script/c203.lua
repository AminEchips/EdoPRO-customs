--EN - Evolution Neo Space (ID: 203)
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Send Fusion Monster to GY, Special Summon 1 "Neo-Spacian" from your GY with the same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)  -- Activated from Spell/Trap Zone
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- Effect 2: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SEND_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.condition2)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)

    -- Effect 3: During End Phase, place "Neo Space" from Deck or GY into the Field Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)  -- Operates from GY
    e3:SetCountLimit(1)
    e3:SetTarget(s.target3)
    e3:SetOperation(s.operation3)
    c:RegisterEffect(e3)
end

-- Effect 1: Send Fusion Monster to GY, Special Summon 1 "Neo-Spacian" from your GY with the same Attribute
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check if there's a Fusion Monster that can be sent to the GY, and a Neo-Spacian in the GY to Special Summon
        return Duel.IsExistingMatchingCard(Card.IsFusionSummonable,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(function(c)
                return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToHand() end,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    -- Send a Fusion Monster to the GY and Special Summon a Neo-Spacian from the GY with the same Attribute
    local tg=Duel.SelectMatchingCard(tp,Card.IsFusionSummonable,tp,LOCATION_MZONE,0,1,1,nil)
    if #tg>0 then
        Duel.SendtoGrave(tg,REASON_EFFECT)
        local special=Duel.SelectMatchingCard(tp,aux.FilterBoolFunction(Card.IsSetCard,0x8),tp,LOCATION_GRAVE,0,1,1,nil)
        if #special>0 then
            Duel.SpecialSummon(special,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Effect 2: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    -- Condition to check if the sent Fusion Monster mentions "Elemental HERO Neos"
    return eg:IsExists(function(c)
        return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and c:IsCode(91427878)  -- Check for "Elemental HERO Neos"
    end,1,nil)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Look for Fusion Monsters that mention "Elemental HERO Neos"
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
    local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,42015635) -- Neo Space code
    if #g>0 then
        -- Move Neo Space to the Field Zone as a Field Spell
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end
