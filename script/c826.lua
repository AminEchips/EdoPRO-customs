--The Phantom Knights of Deathscythe
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Send to GY to Special Summon up to 2 DARK monsters from hand or PZONE
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Effect 2: Quick effect from GY to Xyz/Link Summon using your materials (must include a Phantom Knights)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCondition(s.qscon)
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.qsop)
    c:RegisterEffect(e2)
end

-- ========== EFFECT 1: Special Summon 2 DARK Lvl 4 or lower from hand or Pendulum Zone ==========
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_PZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,nil,e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,2,nil)
    for tc in sg:Iter() do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- Return to hand at End Phase
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetLabelObject(tc)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end
    end
    Duel.SpecialSummonComplete()
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsControler(tp) and tc:IsOnField() then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

-- ========== EFFECT 2: Quick Effect – Xyz/Link summon DARK using your field (including a Phantom Knights) ==========
function s.qscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

function s.qsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
    if not g:IsExists(Card.IsSetCard,1,nil,0x10db) then return end -- Require at least one Phantom Knights monster

    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- Prompt

    local options = {}
    if Duel.GetLocationCountFromEx(tp,tp,g,nil)>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp) then
        table.insert(options,1)
    end
    if Duel.GetLocationCountFromEx(tp,tp,g,nil)>0 and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp) then
        table.insert(options,2)
    end
    if #options==0 then return end

    local opt
    if #options==2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- Xyz / Link
    else
        opt=options[1]-1
    end

    if opt==0 then
        -- Xyz
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyzs=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,g,tp)
        local sc=xyzs:GetFirst()
        if sc then
            Duel.XyzSummon(tp,sc,g)
        end
    else
        -- Link
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local links=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,g,tp)
        local sc=links:GetFirst()
        if sc then
            Duel.LinkSummon(tp,sc,nil,g)
        end
    end
end

function s.xyzfilter(c,mg,tp)
    return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(nil,mg,2,2)
end
function s.linkfilter(c,mg,tp)
    return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLinkSummonable(nil,mg)
end
