--Infernoble Knight Fiery Athen
local s,id=GetID()
function s.initial_effect(c)
    -- Quick Effect: Equip self to Warrior from hand/field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Draw if another monster is destroyed while equipped
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end

-- Equip Target: 1 face-up Warrior you control
function s.eqfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
        and c:IsType(TYPE_MONSTER) and not c:IsForbidden() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e)
        or tc:IsFacedown() or not tc:IsControler(tp) then return end
    if not Duel.Equip(tp,c,tc) then return end
    -- Equip limit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,tc) return tc==e:GetOwner() end)
    c:RegisterEffect(e1)
end

-- Draw condition: a monster is destroyed by battle or effect, but not the equipped monster
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    return ec and eg:IsExists(function(tc) return tc:IsType(TYPE_MONSTER) and tc~=ec end,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end
