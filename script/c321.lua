
--Darklord Sword of Rebellion
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={25451652}

function s.morningstarfilter(c)
    return c:IsFaceup() and c:IsCode(25451652)
end

function s.fusfilter(c,e,tp,mg,f)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and (not f or f(c))
        and Duel.GetFusionMaterial(tp):IsExists(Card.IsCanBeFusionMaterial,2,nil,c)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return true end
    local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    e:SetLabel(opt)
    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g=Duel.SelectTarget(tp,s.morningstarfilter,tp,LOCATION_MZONE,0,1,1,nil)
        e:SetCategory(CATEGORY_ATKCHANGE)
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e2:SetValue(1)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(LOCATION_MZONE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e2)
        end
    else
        local chkf=tp
        local mg=Duel.GetFusionMaterial(tp)
        local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil)
        if #sg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tc=sg:Select(tp,1,1,nil):GetFirst()
            if tc then
                local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
                if not mat or #mat<2 then return end
                tc:SetMaterial(mat)
                Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                Duel.BreakEffect()
                Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
                tc:CompleteProcedure()
            end
        end
    end
end
