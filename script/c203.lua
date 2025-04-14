--EN - Evolution Neo Space
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Activate from hand and place in Spell/Trap Zone as a Continuous Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)  -- Activate from hand
    e1:SetTarget(s.target_activate)  -- Target for activation
    e1:SetOperation(s.operation_activate)  -- Set operation for placing in Spell/Trap Zone
    c:RegisterEffect(e1)

    -- Effect 2: Send Fusion Monster to GY, Special Summon 1 "Neo-Spacian" from your GY with the same Attribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)  -- Only activatable from Spell/Trap Zone
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.target1)
    e2:SetOperation(s.operation1)
    c:RegisterEffect(e2)

    -- Effect 3: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SEND_TO_GRAVE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.condition2)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    c:RegisterEffect(e3)

    -- Effect 4: During End Phase, place "Neo Space" from Deck or GY into the Field Zone
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOFIELD)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_SZONE)  -- Only activates when in Spell/Trap Zone
    e4:SetCountLimit(1)
    e4:SetTarget(s.target3)
    e4:SetOperation(s.operation3)
    c:RegisterEffect(e4)
end

-- Effect 1: Activate from hand and place in Spell/Trap Zone as a Continuous Spell
function s.target_activate(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Can always activate from hand
        return true
    end
    Duel.SetOperationInfo(0,CATEGORY_TOFIELD,nil,1,tp,LOCATION_HAND)  -- Move from hand to Spell/Trap Zone
end

function s.operation_activate(e,tp,eg,ep,ev,re,r,rp)
    -- Move the card to the Spell/Trap Zone as a Continuous Spell
    local c=e:GetHandler()
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

-- Effect 2: Send Fusion Monster to GY, Special Summon 1 "Neo-Spacian" from your GY with the same Attribute
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check for a Fusion Monster on the field and a Neo-Spacian in the GY to Special Summon
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

-- Effect 3: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
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

-- Effect 4: Place "Neo Space" from Deck or GY into the Field Zone
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
