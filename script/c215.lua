--Elemental HERO Wingblade
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,21844576,59793705) -- Avian + Bladedge
    -- Search "E - Emergency Call" on Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Inflict piercing battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)
    -- Lose 800 ATK after attacking
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

function s.thfilter(c)
    return c:IsCode(00213326) and c:IsAbleToHand() -- E - Emergency Call
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsRelateToBattle() and c:GetBattleTarget()~=nil
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetAttack()>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-800)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
