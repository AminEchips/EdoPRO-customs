--Spright Cherry
local s,id=GetID()
function s.initial_effect(c)
    s.listed_series={0x28d} -- Spright
    s.listed_names={68468459} -- Fallen of Albaz

    -- Special Summon itself from hand if you control Level/Link 2 or "Fallen of Albaz" (field or GY)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Trigger: If any monster is Special Summoned from the hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.trigcon)
    e2:SetCost(s.trigcost)
    e2:SetTarget(s.trigtg)
    e2:SetOperation(s.trigop)
    c:RegisterEffect(e2)
end

-- Special Summon procedure: Level/Link 2 OR "Fallen of Albaz" on field or in GY
function s.spfilter(c)
    return c:IsFaceup() and (c:IsLevel(2) or c:IsLink(2)) or c:IsCode(68468459)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end

-- Trigger Condition: If any monster is Special Summoned from the hand
function s.trigcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_HAND) end,1,nil)
end

-- Cost: Send this card from hand or field to GY
function s.trigcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.trigtg(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end

function s.trigop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end

    local lv2_available=g:IsExists(Card.IsLevelAbove,1,nil,1)
    local can_xyz=false
    for tc in g:Iter() do
        if Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,tc) then
            can_xyz=true
            break
        end
    end

    if not lv2_available and not can_xyz then return end

    local opt=0
    if lv2_available and can_xyz then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif lv2_available then
        opt=0
    elseif can_xyz then
        opt=1
    end

    if opt==0 then
        -- Make a monster Level 2
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=g:FilterSelect(tp,Card.IsLevelAbove,1,1,nil,1):GetFirst()
        if tc and tc:IsFaceup() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    else
        -- Xyz Summon using 1 face-up monster
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=g:Filter(Card.IsCanBeXyzMaterial,nil):Select(tp,1,1,nil):GetFirst()
        if not tc then return end

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,tc)
        if #xyzg>0 then
            local sc=xyzg:Select(tp,1,1,nil):GetFirst()
            Duel.XyzSummon(tp,sc,tc)
        end
    end
end
