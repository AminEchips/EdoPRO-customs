--V - Villainous Vengeance
local s,id=GetID()
function s.initial_effect(c)
    -- Activate the Trap Card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_names={94820406}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.ListsCode,94820406),tp,LOCATION_GRAVE,0,nil)
    for tc in g:Iter() do
        if tc:IsType(TYPE_FUSION) and tc:IsPreviousLocation(LOCATION_ONFIELD) and tc:GetTurnID()==Duel.GetTurnCount() then
            return Duel.GetTurnPlayer()~=tp
        end
    end
    return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Must attack this turn, if able
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_MUST_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        -- Halve ATK during damage calculation only
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_SET_ATTACK_FINAL)
        e2:SetValue(tc:GetAttack()//2)
        e2:SetCondition(function(e) return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        tc:RegisterEffect(e2)
    end
end
