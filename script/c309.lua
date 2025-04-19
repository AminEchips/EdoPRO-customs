--Azazel the Sanctified Darklord
local s,id=GetID()
function s.initial_effect(c)
    -- Must be Fusion Summoned using "The Darklord Azazel" and a DARKLORD monster from hand
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,313,s.matfilter)
    
    -- Set 1 "Darklord" Trap from GY, optionally Tribute Summon a "Darklord" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- If tributed or destroyed by battle: destroy 1 Spell/Trap on the field, then draw 1 if it was a Field Spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    c:RegisterEffect(e3)
end
s.listed_names={313}
s.listed_series={0xef}

function s.matfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0xef) and c:IsLocation(LOCATION_HAND)
end

-- Set effect
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
        and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_FIELD)
end
function s.setfilter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.tribute_filter(c)
    return c:IsSetCard(0xef) and c:IsSummonable(true,nil)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SSet(tp,g:GetFirst())>0 then
        Duel.ConfirmCards(1-tp,g)
        -- Optional Tribute Summon
        if Duel.IsExistingMatchingCard(s.tribute_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local tc=Duel.SelectMatchingCard(tp,s.tribute_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
            if tc then
                Duel.Summon(tp,tc,true,nil)
            end
        end
    end
end

-- Destroy effect
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and g:GetFirst():IsType(TYPE_FIELD) then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
