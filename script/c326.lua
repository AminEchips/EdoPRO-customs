--Darklord Deity Morningstar
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,3,3,s.lcheck)

    -- Gains additional attacks based on cards in hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Untargetable if Morningstar material condition met
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.untargetcond)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- Copy and send effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.cost)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end

s.listed_names={25451652} -- Darklord Morningstar
s.listed_series={0xef}

function s.matfilter(c)
    return c:IsSetCard(0xef)
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsLevel,1,nil,12)
end

function s.atkval(e,c)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
end

function s.untargetcond(e)
    local c=e:GetHandler()
    local mg=c:GetMaterial()
    return mg and mg:IsExists(s.mfilter,1,nil)
end
function s.mfilter(c)
    return c:IsCode(25451652) and c:IsSummonType(SUMMON_TYPE_FUSION)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,2000) end
    Duel.PayLPCost(tp,2000)
end

function s.filter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
        local te=tc:CheckActivateEffect(false,true,false)
        if te then
            local tg=te:GetTarget()
            local op=te:GetOperation()
            e:SetCategory(te:GetCategory())
            Duel.ClearTargetCard()
            te:SetOwnerPlayer(tp)
            te:SetActivateLocation(LOCATION_GRAVE)
            if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
            Duel.BreakEffect()
            if op then op(te,tp,eg,ep,ev,re,r,rp) end
        end

        if Duel.GetLP(tp)<Duel.GetLP(1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
            if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.ConfirmCards(1-tp,Duel.GetFieldGroup(tp,LOCATION_HAND,0))
                local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
                local og=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
                if #og>=ct then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                    local sg=og:Select(tp,ct,ct,nil)
                    Duel.SendtoGrave(sg,REASON_EFFECT)
                end
            end
        end
    end
end
