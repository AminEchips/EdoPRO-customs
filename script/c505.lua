-- Altergeist Formatting - Synchro Summon
function s.synfilter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.mfilter1(c,syncard)
    return c:IsCanBeSynchroMaterial(syncard)
end
function s.sytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if not sc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
    local mg=Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_MZONE,0,nil,sc)
    local mat=Duel.SelectSynchroMaterial(tp,sc,nil,mg)
    if #mat==0 then return end
    sc:SetMaterial(mat)
    Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_SYNCHRO)
    Duel.BreakEffect()
    Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
    -- Apply bonus ATK
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    sc:RegisterEffect(e1)
end
