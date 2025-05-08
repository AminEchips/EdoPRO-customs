--Infernoble Knight Commandant Marfisa
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),1,99)
    c:EnableReviveLimit()

    -- Effect 1: Equip FIRE from GY to this card and change Level to 5
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Effect 2: Quick Synchro Summon using this card on the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.syntg)
    e2:SetOperation(s.synop)
    c:RegisterEffect(e2)

    -- Effect 3: Flip a monster face-down if this or equipped monster attacks
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.poscon)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
end
s.listed_series={0x107a}

-- Effect 1 Helpers
function s.eqfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,cc) return cc==e:GetOwner() end)
        e1:SetOwnerPlayer(tp)
        tc:RegisterEffect(e1)
        -- Change level to 5
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_LEVEL)
        e2:SetValue(5)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e2)
    end
end

-- Effect 2 Helpers
function s.matfilter(c,sc,mc)
    return c~=mc and c:IsCanBeSynchroMaterial(sc,mc)
end
function s.synfilter(c,e,tp,mc)
    return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_WARRIOR)
        and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil,c,mc)
        and mc:IsCanBeSynchroMaterial(c)
        and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(mc),c)>0
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local c=e:GetHandler()
        return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsControler(tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
    local sc=g:GetFirst()
    if not sc then return end
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,sc,c)
    if #mg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
    local m2=mg:Select(tp,1,1,nil)
    m2:AddCard(c)
    Duel.SetSynchroMaterial(m2)
    Duel.SynchroSummon(tp,sc,nil)
end

-- Effect 3 Helpers
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    local ec=e:GetHandler()
    return (ec:IsLocation(LOCATION_MZONE) and at==ec)
        or (ec:IsLocation(LOCATION_SZONE) and at:GetEquipGroup():IsContains(ec))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanTurnSet() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end
