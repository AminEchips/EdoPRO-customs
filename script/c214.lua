--Elemental HERO Nova
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials: Burstinatrix + Necroshade
    Fusion.AddProcMix(c,true,true,58932615,89252153)

    --Effect 1: Add "H - Heated Heart" on Fusion Summon
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

    --Effect 2: ATK gain + double damage on attack declaration
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.btg)
    e2:SetOperation(s.bop)
    c:RegisterEffect(e2)
end
s.listed_names={74825788} -- H - Heated Heart
s.material_setcode={0x3008}

-- EFFECT 1: Search on Fusion Summon
function s.thfilter(c)
    return c:IsCode(74825788) and c:IsAbleToHand()
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

-- EFFECT 2: Banish monster, gain ATK, double damage
function s.banfilter(c)
    return c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        -- Gain 500 ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        -- Double battle damage
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            if ep~=tp and Duel.GetAttacker()==e:GetHandler() then
                Duel.ChangeBattleDamage(ep,ev*2)
            end
        end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e2)
    end
end

