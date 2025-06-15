--Salamangreat Hare
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,2,s.matcheck)

    -- Monsters this card points to cannot be selected for attacks
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.battletarget)
    c:RegisterEffect(e1)

    -- Reincarnation: Move & Bounce
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(function(e) return e:GetHandler():IsReincarnationSummoned() end)
    e2:SetTarget(s.movtg)
    e2:SetOperation(s.movop)
    c:RegisterEffect(e2)

    -- If destroyed: Shuffle "Salamangreat" cards (GY/banished) up to opp hand count
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) end)
    e3:SetTarget(s.shtg)
    e3:SetOperation(s.shop)
    c:RegisterEffect(e3)
end
s.listed_series={0x119}

-- Material must be 2 FIRE Effect monsters
function s.matcheck(g,lc,sumtype,tp)
    return g:FilterCount(Card.IsType,nil,TYPE_EFFECT)==#g
end

-- Monsters pointed to by this card cannot be attacked
function s.battletarget(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end

-- Move this card to another MMZ
function s.movtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local c=e:GetHandler()
        for seq=0,4 do
            if Duel.CheckLocation(tp,LOCATION_MZONE,seq) and Duel.GetSequencePosition(tp,c)~=seq then
                return true
            end
        end
        return false
    end
end

function s.movop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
    local seq=math.log(zone,2)
    if Duel.MoveToZone(c,zone,0,0) then
        -- Return all other monsters in the same column
        local colGroup=c:GetColumnGroup():Filter(aux.ExceptThisCard,nil)
        if #colGroup>0 then
            Duel.SendtoHand(colGroup,nil,REASON_EFFECT)
        end
        -- Optional: Return 1 "Salamangreat" you control
        local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(0x119) and c:IsAbleToHand() end,tp,LOCATION_MZONE,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
        end
    end
end

-- Shuffle up to opponent's hand count of "Salamangreat" from GY/banished
function s.shfilter(c)
    return c:IsSetCard(0x119) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
