--Evil HERO Traumosphere
local s,id=GetID()
function s.initial_effect(c)
    -- Choose 1 effect on Normal or Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Trigger when banished from hand
    local e3=e1:Clone()
    e3:SetCode(EVENT_REMOVE)
    e3:SetCondition(s.rmcon)
    c:RegisterEffect(e3)
end

s.listed_names={94820406} -- Dark Fusion

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_HAND)
end

function s.filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(94820406) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local fiendCheck=Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND)
        local stCheck=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
        return fiendCheck or stCheck
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND)
    local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)

    if not (b1 or b2) then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local op=Duel.SelectOption(tp,
        b1 and aux.Stringid(id,2) or nil,
        b2 and aux.Stringid(id,3) or nil)

    if op==0 and b1 then
        local ct=Duel.GetMatchingGroupCount(Card.IsLevelAbove,tp,LOCATION_MZONE,0,nil,5)
        if ct==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    elseif op==1 and b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end
