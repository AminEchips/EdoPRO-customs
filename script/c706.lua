--World Legacy Noble Arms - Arthur's Crown
local s,id=GetID()
function s.initial_effect(c)
    -- Equip from hand or field to Noble Knight
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- GY Quick Effect: Recycle 3 banished Noble Knights and revive LIGHT Warrior
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series={0x107a,0x149} -- Noble Knight + Roland

-- Equip target
function s.eqfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x107a)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
        Duel.SendtoGrave(c,REASON_EFFECT)
        return
    end
    Duel.Equip(tp,c,tc,true)

    -- Equip limit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return c==e:GetOwner():GetEquipTarget() end)
    c:RegisterEffect(e1)

    -- Gain 300 ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(300)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- Become LIGHT
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e4:SetValue(ATTRIBUTE_LIGHT)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e4)

    -- Tribute to summon Synchro 4 Levels higher (Roland only)
    if tc:IsSetCard(0x149) then
        local e5=Effect.CreateEffect(c)
        e5:SetDescription(aux.Stringid(id,2))
        e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e5:SetType(EFFECT_TYPE_IGNITION)
        e5:SetRange(LOCATION_SZONE)
        e5:SetCountLimit(1,{id,2})
        e5:SetTarget(s.rltg)
        e5:SetOperation(s.rlop)
        c:RegisterEffect(e5)
    end
end

-- Roland effect: Summon Synchro 4 levels higher
function s.synfilter(c,lv,e,tp)
    return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_SYNCHRO)
        and c:GetLevel()==lv+4 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ec=e:GetHandler()
    local tc=ec:GetEquipTarget()
    if chk==0 then
        return tc and tc:IsReleasable()
            and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tc:GetLevel(),e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler()
    local tc=ec:GetEquipTarget()
    if not tc or not tc:IsReleasable() then return end
    local lv=tc:GetLevel()
    if Duel.Release(tc,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
    end
end

-- GY Quick Effect: Recycle and revive
function s.tdfilter(c)
    return c:IsSetCard(0x107a) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    if #g==3 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
