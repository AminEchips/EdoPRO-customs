--I - Infernal Blast
local s,id=GetID()
function s.initial_effect(c)
    -- Activate and equip to 1 monster Special Summoned to your opponent's field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.eqcon)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Burn and destroy during Standby Phase
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.burncon)
    e2:SetTarget(s.burntg)
    e2:SetOperation(s.burnop)
    c:RegisterEffect(e2)

    -- Indestructible by card effects if "Dark Fusion" is in your GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

s.listed_names={94820406} -- Dark Fusion

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:FilterCount(Card.IsControler,nil,1-tp)==1 and eg:GetCount()==1
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:GetFirst():IsFaceup() end
    Duel.SetTargetCard(eg:GetFirst())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
    end
end

function s.burncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetEquipTarget()
    if tc then
        Duel.Damage(1-tp,1000,REASON_EFFECT)
        local g=Duel.SelectMatchingCard(tp,nil,1-tp,LOCATION_ONFIELD,0,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end

function s.indcon(e)
    return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,94820406)
end
