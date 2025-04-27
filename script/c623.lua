--Blackwing - Roost
local s,id=GetID()
function s.initial_effect(c)
    -- Burn when a monster is summoned (optional)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(3)
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- Double ATK when Black-Winged Dragon or a monster that lists it becomes 0
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ADJUST)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.dblcon)
    e2:SetTarget(s.dbltg)
    e2:SetOperation(s.dblop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- Bounce when this leaves the field because of opponent
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.bouncecon)
    e3:SetTarget(s.bouncetg)
    e3:SetOperation(s.bounceop)
    c:RegisterEffect(e3)
end

s.listed_names={9012916}

-------------------------------------------------------
-- 1st effect: Burn
-------------------------------------------------------
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(350)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,350)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Damage(p,d,REASON_EFFECT)
    end
end

-------------------------------------------------------
-- 2nd effect: Double ATK
-------------------------------------------------------
function s.dblfilter(c)
    return c:IsFaceup() and c:GetAttack()==0 and (c:IsCode(9012916) or c:ListsCode(9012916))
end
function s.dblcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.dbltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.dblfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetTargetCard(g)
end
function s.dblop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local base_atk=tc:GetBaseAttack()
        if base_atk>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(base_atk*2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e1)
        end
    end
end

-------------------------------------------------------
-- 3rd effect: Bounce when leaves field
-------------------------------------------------------
function s.bouncecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
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
