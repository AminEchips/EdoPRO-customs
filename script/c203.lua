--EN - Evolution Neo Space (ID: 203)
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Send 1 Fusion Monster to the GY, and Special Summon 1 "Neo-Spacian" monster from your GY with the same Attribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- Effect 2: If Fusion Monster(s) that mentions "Elemental HERO Neos" is sent to the GY, shuffle them into the Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)

    -- Effect 3: During the End Phase, place "Neo Space" from your Deck or GY into the Field Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.target3)
    e3:SetOperation(s.operation3)
    c:RegisterEffect(e3)

    -- Effect 4: Activate "EN - Evolution Neo Space" from hand and place it in the Spell/Trap Zone
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_TOFIELD)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetTarget(s.target4)
    e4:SetOperation(s.operation4)
    c:RegisterEffect(e4)
end

-- Effect 1: Send Fusion Monster to GY and Special Summon Neo-Spacian
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFusionSummonable,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.SelectMatchingCard(tp,Card.IsFusionSummonable,tp,LOCATION_MZONE,0,1,1,nil)
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
        return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
end

-- Effect 3: Place "Neo Space" from Deck or GY into the Field Zone
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,91427878) -- Neo Space's code
    end
    Duel.SetOperationInfo(0,CATEGORY_TOFIELD,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.operation3(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,91427878) -- Neo Space's code
    if #g>0 then
        -- Move Neo Space to the Field Zone as a Field Spell
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end

-- Effect 4: Activate "EN - Evolution Neo Space" from hand and place it in the Spell/Trap Zone
function s.target4(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return true  -- You can always activate this card from hand
    end
    Duel.SetOperationInfo(0,CATEGORY_TOFIELD,nil,1,tp,LOCATION_HAND)  -- Correct category for Field Spell
end

function s.operation4(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Move Evolution Neo Space from the hand to the Spell/Trap Zone as a Field Spell
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end
