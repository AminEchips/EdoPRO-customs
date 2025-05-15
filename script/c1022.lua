--Springans Sprinder 3000
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Xyz summon
    Xyz.AddProcedure(c,s.mfilter,4,2)
    
    --Search Gold Golgonda or card that mentions it
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --Banish Xyz, become 3000 ATK, destroy 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMINGS_CHECK_MONSTER_E+TIMING_BATTLE_PHASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end
s.listed_names={68468459,11110587} -- Fallen of Albaz, Gold Golgonda
s.listed_series={SET_SPRINGANS}

function s.mfilter(c,lc,sumtype,tp)
    return c:IsRace(RACE_PYRO,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_FIRE,lc,sumtype,tp) or c:IsCode(68468459)
end

--Search effect
function s.thfilter(c)
    return c:IsAbleToHand() and (c:IsCode(11110587) or c:ListsCode(11110587))
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

--Quick effect
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
function s.xyzbanfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.xyzbanfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
            and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp,s.xyzbanfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(3000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #dg>0 then
                Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end
