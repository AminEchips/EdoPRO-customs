--Infernoble Knight Commandant Marfisa
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),1,99)
    c:EnableReviveLimit()

    -- Effect 1: Equip FIRE from GY to this card, reduce Level to 5
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e) return e:GetHandler():GetLevel()==6 end)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Effect 2: When this card becomes equipped, Synchro Summon + Equip
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_EQUIP)
    e2:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_MZONE) end)
    e2:SetOperation(s.synop)
    c:RegisterEffect(e2)

    -- Effect 3: Flip target on attack (whether equipped or attacking itself)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.poscon)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
end

s.listed_series={0x107a}

-- Effect 1: Equip a FIRE from GY to this card
function s.eqfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local ec=g:GetFirst()
    if ec and Duel.Equip(tp,ec,c) then
        -- Set equip limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==e:GetOwner() end)
        ec:RegisterEffect(e1)
        -- Reduce level
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_LEVEL)
        e2:SetValue(5)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e2)
    end
end

-- Effect 2: Synchro summon when equipped, then optionally equip this card from GY
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsControler(tp) or not c:IsAbleToGrave() then return end
    if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanBeSynchroMaterial),tp,LOCATION_MZONE,0,1,c) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SYNCHRO)
    local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_SYNCHRO)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_SYNCHRO)
    local sc=g:GetFirst()
    if not sc then return end

    Duel.SendtoGrave(c,REASON_EFFECT) -- Send this to GY to use as material
    if Duel.SynchroSummon(tp,sc,nil)==0 then return end

    if c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Equip(tp,c,sc)
        -- Equip limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==e:GetOwner() end)
        c:RegisterEffect(e1)
    end
end

-- Effect 3: Flip 1 monster if this or equipped monster attacks
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    local ec=e:GetHandler()
    return (ec:IsLocation(LOCATION_MZONE) and at==ec)
        or (ec:IsLocation(LOCATION_SZONE) and at:GetEquipGroup():IsContains(ec))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanTurnSet() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end
