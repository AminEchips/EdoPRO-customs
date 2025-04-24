--Altergeist Network
local s,id=GetID()
function s.initial_effect(c)
    --Activate: Target 1 "Altergeist" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Set from Deck if sent from field this turn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

s.listed_series={0x103}

function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x103)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        -- Gain ATK equal to total Link Rating * 300
        local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)
        local total_link = 0
        for link in g:Iter() do
            total_link = total_link + link:GetLink()
        end
        local atk_gain = total_link * 300
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk_gain)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)

        -- Negate the effects of any monster it attacks
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_ATTACK_ANNOUNCE)
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetCondition(function(ev,tp,eg,ep,ev,re,r,rp)
            return Duel.GetAttacker()==tc and Duel.GetAttackTarget()
        end)
        e2:SetOperation(function(ev,tp,eg,ep,ev,re,r,rp)
            local bc=Duel.GetAttackTarget()
            if bc and bc:IsRelateToBattle() then
                local e3=Effect.CreateEffect(e:GetHandler())
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_DISABLE)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                bc:RegisterEffect(e3)
                local e4=Effect.CreateEffect(e:GetHandler())
                e4:SetType(EFFECT_TYPE_SINGLE)
                e4:SetCode(EFFECT_DISABLE_EFFECT)
                e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                bc:RegisterEffect(e4)
            end
        end)
        Duel.RegisterEffect(e2,tp)
    end
end

-- Check if this card was sent from the field to the GY this turn
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==Duel.GetTurnCount()
end

function s.setfilter(c)
    return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and not c:IsCode(id) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end
