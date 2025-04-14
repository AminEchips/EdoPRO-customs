-- EN - Evolution Neo Space
-- Scripted by: Your Name

local s,id=GetID()

function s.initial_effect(c)
    -- Effect 1: Activate from hand and place in Spell/Trap Zone
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.activate_target)
    e1:SetOperation(s.activate_operation)
    c:RegisterEffect(e1)

    -- Effect 2: Continuous effect while on the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8))  -- Targets "Neo-Spacian" monsters
    e2:SetValue(aux.tgoval)
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
function s.activate_target(e,tp,eg,ep,ev,re,r,rp,chk)
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

-- Effect 2: Continuous effect while on the field
-- This effect ensures "Neo-Spacian" monsters cannot be targeted
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    -- Condition: Check if Fusion Monsters related to "Elemental HERO Neos" are sent to the GY
    return eg:IsExists(function(c)
        return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and c:IsCode(89943723)  -- Check for "Elemental HERO Neos"
    end,1,nil)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check if there are Fusion Monsters related to "Elemental HERO Neos"
        return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    -- Shuffle Fusion Monsters related to "Elemental HERO Neos" into the Extra Deck
    local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
end

-- Effect 3: During End Phase, place "Neo Space" from Deck or GY into the Field Zone
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

