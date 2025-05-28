--Supreme Summon
--Scripted by Meuh
local s,id=GetID()
function s.initial_effect(c)
    -- Activate (no effect, just activation)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Only 1 Supreme Summon
    c:SetUniqueOnField(1,0,id)

    -- Choose 1 of 4 effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Check for valid activation of at least one effect
function s.tgfilter(c)
    return c:IsFaceup() or c:IsFacedown()
end
function s.spellfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsSSetable()
        and not c:IsCode(id) and c:ListsCode(13331639) -- "Supreme King Z-ARC"
end
function s.fdfilter(c)
    return c:IsFacedown() and c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(8)
end
function s.revfilter(c)
    return c:IsSetCard(0x20f8) or c:IsCode(13331639) -- "Supreme King Dragon" or "Z-ARC"
end
function s.gytargetfilter(c,e,tp)
    return (c:IsSetCard(0x20f8) or c:IsCode(13331639)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.fieldfilter(c)
    return c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.fdfilter,tp,LOCATION_EXTRA,0,1,nil)
    local b3=Duel.IsExistingMatchingCard(s.gytargetfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b4=Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)

    if chk==0 then return b1 or b2 or b3 or b4 end
    local op=0
    if b1 and not b2 and not b3 and not b4 then op=0
    elseif not b1 and b2 and not b3 and not b4 then op=1
    elseif not b1 and not b2 and b3 and not b4 then op=2
    elseif not b1 and not b2 and not b3 and b4 then op=3
    else
        op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,1)},
            {b2,aux.Stringid(id,2)},
            {b3,aux.Stringid(id,3)},
            {b4,aux.Stringid(id,4)})
        op=op-1
    end
    e:SetLabel(op)
    if op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectTarget(tp,s.gytargetfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    elseif op==3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectTarget(tp,s.fieldfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        -- Effect 1: Send from Extra Deck, set Spell/Trap
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil)
        if #g==0 then return end
        Duel.SendtoGrave(g,REASON_COST)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SSet(tp,sg)
        end
    elseif op==1 then
        -- Effect 2: Reveal face-down Pendulum, discard 1, place it in Pendulum Zone
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_EXTRA,0,1,1,nil)
        if #g==0 then return end
        local tc=g:GetFirst()
        Duel.ConfirmCards(1-tp,tc)
        if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
            Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
    elseif op==2 then
        -- Effect 3: Target and Special Summon, ignoring conditions
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
        end
    elseif op==3 then
        -- Effect 4: Target and banish 1 card
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end
end
