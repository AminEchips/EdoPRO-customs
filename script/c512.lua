--Altergeist Harpydrive
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,nil,2,99,s.lcheck)

    -- Set 1 Trap from hand, can activate this turn
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- If sent from field to GY: Choose 1 you control and 1 your opponent controls, banish when they leave
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.bancon)
    e2:SetTarget(s.bantg)
    e2:SetOperation(s.banop)
    c:RegisterEffect(e2)

    -- GY effect: Banish to draw 1
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

s.listed_series={0x103}
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end

-- Effect 1: Set 1 Trap from hand
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.setfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        Duel.SSet(tp,tc)
        -- Can activate this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- Effect 2: If sent to GY, flag 1 you control and 1 opponent control to banish
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.banfilter(c)
    return c:IsFaceup() and c:IsAbleToRemove()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.banfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g1=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    g1:Merge(g2)
    for tc in g1:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        tc:RegisterEffect(e1,true)
    end
end

-- Effect 3: GY Draw
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end
