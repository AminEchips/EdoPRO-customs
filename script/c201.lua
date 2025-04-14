--Elemental HERO Plasma Soldier
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Set 1 Trap with "HERO" in text on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Effect 2: GY Attribute change
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ANNOUNCE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+100)
    e3:SetCost(s.attrcost)
    e3:SetTarget(s.attrtg)
    e3:SetOperation(s.attrop)
    c:RegisterEffect(e3)
end

-- Effect 1: Set 1 Trap that mentions "HERO"
function s.setfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsSSetable() and c:ListsArchetype(0x3008)
end


function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,0,nil,1,tp,LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end


-- Effect 2: Attribute Change from GY
function s.attrcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.attrtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
    local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
    e:SetLabel(attr)
end

function s.attrop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(e:GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

s.listed_series={0x8}
