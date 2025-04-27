--Blackwing - Roost
local s,id=GetID()
function s.initial_effect(c)
    -- 3x per turn: Inflict 350 damage on Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.damcon)
    e1:SetOperation(s.damop)
    e1:SetCountLimit(3)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ATK 0 Black-Winged Dragon: Double ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.dblcon)
    e3:SetTarget(s.dbltg)
    e3:SetOperation(s.dblop)
    e3:SetCountLimit(1,id)
    c:RegisterEffect(e3)

    -- If this card leaves field: Bounce opponent's monsters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.bouncecon)
    e4:SetTarget(s.bouncetg)
    e4:SetOperation(s.bounceop)
    c:RegisterEffect(e4)
end
s.listed_names={9012916} -- Black-Winged Dragon

------------------------------------------------------------
-- (1) Inflict 350 on Summon (up to 3x/turn)
------------------------------------------------------------
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsFaceup,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        Duel.Damage(tc:GetControler(),350,REASON_EFFECT)
    end
end

------------------------------------------------------------
-- (2) Double ATK when Black-Winged Dragon reaches 0 ATK
------------------------------------------------------------
function s.atkfilter(c)
    return c:IsFaceup() and c:IsCode(9012916) and c:GetAttack()==0
end
function s.dblcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.dbltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetTargetCard(g)
end
function s.dblop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local ct=tc:GetCounter(0x1002)
        if ct>0 then
            tc:RemoveCounter(tp,0x1002,ct,REASON_EFFECT)
        end
        if tc:IsFaceup() and tc:IsCode(9012916) then
            local atk=tc:GetBaseAttack()
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(atk*2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e1)
        end
    end
end

------------------------------------------------------------
-- (3) Bounce opponent's monsters if this card leaves field
------------------------------------------------------------
function s.bouncecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
