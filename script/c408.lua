--Starry Knight Nebulael
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,4,2,s.ovfilter,aux.Stringid(id,0),2,nil)
    c:EnableReviveLimit()

    -- ATK & DEF increase for your LIGHT monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.atktg)
    e1:SetValue(500)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e1b)

    -- ATK & DEF decrease for opponent's DARK monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetTarget(s.atktg2)
    e2:SetValue(-500)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2b)

    -- All opponent monsters become DARK
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)

    -- Destroy 1 card on the field when a card is destroyed by a card effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.descon)
    e4:SetCost(s.descost)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end

function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsLevel(4) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.atktg(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c~=e:GetHandler()
end
function s.atktg2(e,c)
    return c:IsAttribute(ATTRIBUTE_DARK)
end

-- Only trigger if a card was destroyed by effect this turn
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)>0
end

-- Pay cost by detaching 1 material
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Target any card on the field
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Destroy it
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- Global check for any card destroyed by effect this turn
if not s.global_check then
    s.global_check=true
    local ge1=Effect.CreateEffect(s)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_DESTROYED)
    ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if eg:IsExists(Card.IsReason,1,nil,REASON_EFFECT) then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    end)
    Duel.RegisterEffect(ge1,0)
end
