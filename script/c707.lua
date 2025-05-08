-- Effect 3: Flip any monster on attack (this or equipped monster)
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,2))
e3:SetCategory(CATEGORY_POSITION)
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e3:SetCode(EVENT_ATTACK_ANNOUNCE)
e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
e3:SetCountLimit(1,{id,2})
e3:SetCondition(s.poscon)
e3:SetTarget(s.postg)
e3:SetOperation(s.posop)
c:RegisterEffect(e3)

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    local ec=e:GetHandler()
    return (ec:IsLocation(LOCATION_MZONE) and at==ec)
        or (ec:IsLocation(LOCATION_SZONE) and at:GetEquipGroup():IsContains(ec))
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanTurnSet() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end
