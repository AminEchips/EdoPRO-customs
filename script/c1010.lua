--Alactran the Thunderstorm Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Materials
    Fusion.AddProcMix(c,true,true,68468459,s.matfilter) -- Fallen of Albaz + Level/Rank/Link 2
    --Can be treated as Level 2 for Xyz Summon
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_XYZ_LEVEL)
    e0:SetValue(2)
    c:RegisterEffect(e0)
    --Battle: change ATK/DEF of opponent's monster to 0
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --If sent to GY this turn → End Phase search/summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
end
s.listed_names={68468459}
s.listed_series={0x181} -- Spright

-- Fusion requirement: any Level/Rank/Link 2 monster
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(2) or c:IsRank(2) or (c:IsType(TYPE_LINK) and c:GetLink()==2)
end

-- If battling Lvl/Rank/Link 3+ monster
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp) and bc:IsFaceup() and
        (bc:IsLevelAbove(3) or bc:IsRankAbove(3) or (bc:IsType(TYPE_LINK) and bc:GetLink()>=3))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        bc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        bc:RegisterEffect(e2)
    end
end

-- Register GY effect for End Phase trigger
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

-- Search/Summon Spright or Albaz
function s.thfilter(c,e,tp,ft)
    return c:IsMonster() and (c:IsSetCard(0x181) or c:IsCode(68468459))
        and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
    local tc=g:GetFirst()
    if tc then
        aux.ToHandOrElse(tc,tp,
            function(c) return ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
            function(c) Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
            aux.Stringid(id,2))
    end
end
