--Darklord Deity Morningstar
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Link Summon procedure
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xef),3,3,s.lcheck)

    -- Untargetable if a material was Fusion Summoned using Darklord Morningstar
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.untargetable_con)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Gains extra attacks based on hand size
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.exatkval)
    c:RegisterEffect(e2)

    -- Copy Darklord Spell/Trap effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end
s.listed_names={25451652} -- Darklord Morningstar
s.listed_series={0xef} -- Darklord

-- Must include "The First Darklord" as 1 material
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsCode,1,nil,75041269)
end

-- Check for Fusion Summoned Darklord Morningstar material
function s.untargetable_con(e)
    local c=e:GetHandler()
    local mg=c:GetMaterial()
    return mg and mg:IsExists(s.matfilter,1,nil)
end
function s.matfilter(c)
    return c:IsCode(25451652) and c:IsSummonType(SUMMON_TYPE_FUSION)
end

-- Extra Attacks
function s.exatkval(e,c)
    return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)
end

-- Effect 3: Cost - Pay 2000 LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,2000) end
    Duel.PayLPCost(tp,2000)
end

-- Target 1 Darklord Normal Spell/Trap in Deck or Hand
function s.filter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsType(TYPE_CONTINUOUS)
        and c:GetType()&0x20004==0x20004 -- Normal Spell/Trap
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
end

-- Operation: Copy effect, then optionally reveal & send
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end

    Duel.SendtoGrave(tc,REASON_EFFECT)
    local te=tc:CheckActivateEffect(false,true,true)
    if te then
        local tg=te:GetTarget()
        local op=te:GetOperation()
        if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
        Duel.BreakEffect()
        if op then op(e,tp,eg,ep,ev,re,r,rp) end
    end

    -- Optional follow-up effect if LP < opponent's
    if Duel.GetLP(tp)<Duel.GetLP(1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            local hand=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            Duel.ConfirmCards(1-tp,hand)
            local ct=#hand
            local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
            if #g>=ct then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local tg=g:Select(tp,ct,ct,nil)
                Duel.SendtoGrave(tg,REASON_EFFECT)
                Duel.SendtoGrave(hand,REASON_EFFECT+REASON_DISCARD)
            else
                Duel.ShuffleHand(tp) -- not enough targets
            end
        end
    end
end
