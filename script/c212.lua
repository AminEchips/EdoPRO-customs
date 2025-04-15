--Hope for Neo Space
local s,id=GetID()
function s.initial_effect(c)
    --Activate one of three effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={89943723} -- Elemental HERO Neos
s.listed_series={0x3008,0x8} -- Neo-Spacian, Elemental HERO

function s.filter1(c)
    return c:IsFaceup() and (c:IsSetCard(0x3008) or c:IsSetCard(0x1f))
end
function s.filter2(c)
    return c:IsFaceup() and c:IsCode(89943723)
end
function s.filter3(c)
    return c:IsType(TYPE_SPELL) and c:IsCode(24094653) and c:IsAbleToGrave()
end
function s.filter_neos(c)
    return c:IsFaceup() and c:IsCode(89943723) and c:IsAbleToGrave()
end
function s.filter_spacian(c)
    return c:IsFaceup() and c:IsSetCard(0x1f) and c:IsAbleToGrave()
end
function s.filter_lv12hero(c,e,tp)
    return c:IsLevel(12) and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
    local b3=Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter_neos,tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetMatchingGroupCount(s.filter_spacian,tp,LOCATION_MZONE,0,nil)>=2
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter_lv12hero,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    if chk==0 then return b1 or b2 or b3 end
    local op=0
    if b1 and b2 and b3 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 and b3 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))
        if op==1 then op=2 end
    elseif b2 and b3 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    elseif b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,3))+2
    end
    e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
    elseif op==2 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        local ct=Duel.GetMatchingGroupCount(s.filter1,tp,LOCATION_MZONE,0,nil)
        if ct>0 then
            Duel.Recover(tp,ct*1000,REASON_EFFECT)
        end
    elseif op==1 then
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local poly=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_HAND,0,1,1,nil)
        local neos=Duel.SelectMatchingCard(tp,s.filter_neos,tp,LOCATION_MZONE,0,1,1,nil)
        local spacians=Duel.SelectMatchingCard(tp,s.filter_spacian,tp,LOCATION_MZONE,0,2,2,nil)
        if #poly==1 and #neos==1 and #spacians==2 then
            local fullgroup=poly+neos+spacians
            if Duel.SendtoGrave(fullgroup,REASON_EFFECT)==4 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sc=Duel.SelectMatchingCard(tp,s.filter_lv12hero,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
                if sc then
                    Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)
                    sc:CompleteProcedure()
                end
            end
        end
    end
end
