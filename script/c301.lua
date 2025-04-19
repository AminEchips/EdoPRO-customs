--Darklord Valkyria
local s,id=GetID()
function s.initial_effect(c)
    -- Can only be Special Summoned once per turn
    c:SetSPSummonOnce(id)

    -- Effect 1: Gain ATK + destroy Spell/Trap immediately if Morningstar is on field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Effect 2: Special Summon self if sent to GY as cost for a Darklord effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_names={25451652}

-- Spell/Trap filter (face-up or face-down)
function s.desfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

-- Effect 1: Always gain 300 ATK, destroy 1 Spell/Trap if Morningstar is present
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,25451652) and
       Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
    end
end


function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end

    -- Always gain 300 ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(300)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    -- Optional destruction if Morningstar is on field
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,25451652) then
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=g:Select(tp,1,1,nil)
            Duel.HintSelection(dg)
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end

-- Effect 2: Revive self if sent to GY as cost by a Darklord card
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return re and re:GetHandler():IsSetCard(0xef) and c:IsReason(REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
