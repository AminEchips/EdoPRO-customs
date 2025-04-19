--Darklord Deity Morningstar
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,3,3,s.lcheck)

    -- Gains additional attacks based on cards in hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Untargetable if Morningstar material condition met
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.untargetcond)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Copy and send effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    
end

s.listed_names={25451652,04167084} -- Darklord Morningstar
s.listed_series={0xef}

function s.matfilter(c)
    return c:IsSetCard(0xef)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsLevel,1,nil,12)
end

function s.atkval(e,c)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
end

function s.untargetcond(e)
    local c=e:GetHandler()
    local mg=c:GetMaterial()
    return mg and mg:IsExists(s.mfilter,1,nil)
end
function s.mfilter(c)
    return c:IsCode(04167084) and c:IsSummonType(SUMMON_TYPE_FUSION)
end

-- Cost: Pay 2000 LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,2000) end
    Duel.PayLPCost(tp,2000)
end

-- Filter for Darklord Normal Spell/Trap
function s.filter(c,tp)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsType(TYPE_NORMAL) and c:CheckActivateEffect(false,true,false)~=nil
end

-- Target check for Deck/Hand copy source
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end

-- Main operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if not tc then return end

    local te=tc:CheckActivateEffect(false,true,true)
    if Duel.SendtoGrave(tc,REASON_EFFECT)==0 or not te then return end

    local tg=te:GetTarget()
    local op=te:GetOperation()
    if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
    Duel.BreakEffect()
    if op then op(e,tp,eg,ep,ev,re,r,rp) end

    -- Optional LP difference effect
    local hand=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    local ct=#hand
    if Duel.GetLP(tp)<Duel.GetLP(1-tp) and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.ConfirmCards(1-tp,hand)
        local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
        if #g>=ct then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=g:Select(tp,ct,ct,nil)
            Duel.SendtoGrave(tg,REASON_EFFECT)
            Duel.SendtoGrave(hand,REASON_EFFECT+REASON_DISCARD)
        else
            Duel.ShuffleHand(tp) -- Failsafe
        end
    end
end
