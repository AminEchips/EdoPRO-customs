--Elemental HERO Electaser
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Special Summon if added to hand except by drawing
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Effect 2: Tribute and revive non-LIGHT banished HERO
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Effect 3: ATK boost and protection
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end
s.listed_series={0x8}

-- Effect 1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsReason(REASON_DRAW)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Effect 2
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.filter(c,e,tp)
    return c:IsSetCard(0x8) and not c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Effect 3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x8),tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsLevel,10),tp,LOCATION_MZONE,0,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE+LOCATION_MZONE,LOCATION_MZONE,nil)
    local attrs={}
    for tc in g:Iter() do
        local attr=tc:GetAttribute()
        if not attrs[attr] then attrs[attr]=true end
    end
    local count=0
    for _,v in pairs(attrs) do
        count=count+1
    end
    if count>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(count*500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)

        -- Banish this card and protect
        if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
            local sc=Duel.GetFirstMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
            if sc then
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
                e2:SetValue(1)
                e2:SetReset(RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e2)
            end
        end
    end
end
