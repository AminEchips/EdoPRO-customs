--Blackwing - Perching
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and Set 1 Spell/Trap that mentions "Black-Winged Dragon" or "Blackwing"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- GY effect: Banish to treat Synchro Monster as Tuner/Non-Tuner
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(aux.bfgcost) -- banish itself as cost
    e2:SetTarget(s.tg)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
end
s.listed_names={9012916} -- Black-Winged Dragon
s.listed_series={0x33} -- Blackwing

-----------------------------------------------------------
-- Activation effect: Set 1 Whirlwind Spell/Trap
-----------------------------------------------------------
function s.setfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) 
        and (c:ListsCode(9012916) or (c:ListsArchetype(0x33) or c:IsCode(810000056,511000777,511002900,511004427,511009526,09925982,511002211,810000051,810000052,511002795))
        and not c:IsCode(id)
        and c:IsSSetable())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
        Duel.ConfirmCards(1-tp,g)
    end
end

-----------------------------------------------------------
-- GY effect: Make Synchro Monster Tuner or Non-Tuner
-----------------------------------------------------------
function s.synfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.synfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.synfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        if opt==0 then
            e1:SetCode(EFFECT_ADD_TYPE)
            e1:SetValue(TYPE_TUNER)
        else
            e1:SetCode(EFFECT_REMOVE_TYPE)
            e1:SetValue(TYPE_TUNER)
        end
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
