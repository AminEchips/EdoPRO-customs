--The Phantom Knights of Chosen Sword
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon procedure
    Xyz.AddProcedure(c,nil,4,2)
    c:EnableReviveLimit()
    
    --Alternative Xyz Summon using a Rank 3 DARK Xyz Monster with no materials
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetTarget(s.xyztg)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    --Gain ATK for each face-up "Phantom Knights" card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    --Attach banished Trap & optionally bounce
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.attachcon)
    e2:SetOperation(s.attachop)
    c:RegisterEffect(e2)

    --Destruction protection
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

--Alternative Xyz Summon using Rank 3 DARK Xyz with no materials
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsRank(3) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function s.xyzcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
        and Duel.IsExistingMatchingCard(s.xyzfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        e:SetLabelObject(g:GetFirst())
        return true
    end
    return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    if not tc then return end
    c:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(c,Group.FromCards(tc))
end

--Gain 200 ATK for each face-up "Phantom Knights" card
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x10db)
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*200
end

--Attach Trap from banished and optionally return 1 card
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local traps=eg:Filter(Card.IsType,nil,TYPE_TRAP):Filter(Card.IsAbleToChangeControler,nil)
    if #traps==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local tc=traps:Select(tp,1,1,nil):GetFirst()
    if tc then
        Duel.Overlay(c,Group.FromCards(tc))
        if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
            end
        end
    end
end

--Destruction replacement
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT+REASON_REPLACE) end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT+REASON_REPLACE)
end
