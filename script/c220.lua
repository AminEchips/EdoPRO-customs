--Elemental HERO Riptide
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,59793705,79979666) -- Bladedge + Bubbleman
    s.listed_names={59793705,79979666}

    -- Piercing damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e1)

    -- Draw on battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=1
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsControler,tp),tp,LOCATION_MZONE,0,1,e:GetHandler())==false then
        ct=2
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
