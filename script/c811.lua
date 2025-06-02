--Raidraptor - Phantom Eagle
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    Xyz.AddProcedure(c,nil,3,2)
    c:EnableReviveLimit()

    -- Gain ATK equal to damage taken (mandatory trigger)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Set or attach a Raidraptor/Phantom Knights Trap from hand or Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.setcon)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- Draw 1 if destroyed by battle or monster effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.drcon)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

-------------------
-- Effect 1: ATK gain
-------------------
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ev)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-------------------
-- Effect 2: Set/Attach Trap
-------------------
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return eg:IsExists(function(tc)
        return tc:IsType(TYPE_MONSTER)
            and tc:IsPreviousLocation(LOCATION_MZONE)
            and tc:IsReason(REASON_BATTLE+REASON_EFFECT)
            and tc~=c
    end,1,nil)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.setfilter(c)
    return c:IsType(TYPE_TRAP)
        and (c:IsSetCard(0xba) or c:IsSetCard(0xdb))
        and (c:IsSSetable() or c:IsAbleToOverlay())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- "Set it", "Attach it"
    if opt==0 and tc:IsSSetable() then
        Duel.SSet(tp,tc)
    elseif opt==1 and tc:IsAbleToOverlay() then
        Duel.Overlay(e:GetHandler(),Group.FromCards(tc))
    end
end

-------------------
-- Effect 3: Draw on destruction
-------------------
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsSummonType(SUMMON_TYPE_XYZ)
        and (r&REASON_BATTLE~=0 or (r&REASON_EFFECT~=0 and re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)))
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
