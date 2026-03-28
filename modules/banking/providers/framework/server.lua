-- modules/banking/providers/framework/server.lua
-- FRAMEWORK bank provider.
-- Player bank  : delegates to sp.getMoney / sp.addMoney / sp.removeMoney
--                (framework layer, 'bank' money type).
-- Society      : NOT supported — framework money has no society concept.
--                All society calls return safe no-op defaults (0 / false).
-- Register as the framework-layer bank provider for:
--   Bankings.FRAMEWORK       : explicit framework money routing
--   Bankings.ESX_BANKING     : esx_banking detected but no dedicated provider in Beta 1
--   Bankings.ESX_ADDON_ACCOUNT: esx_addonaccount detected but no dedicated provider in Beta 1
-- In the latter two cases we fall back to sp.getMoney/addMoney/removeMoney('bank'),
-- which is a best-effort approximation rather than a full esx_banking integration.
local handled = sp.banking == Bankings.FRAMEWORK
    or sp.banking == Bankings.ESX_BANKING
    or sp.banking == Bankings.ESX_ADDON_ACCOUNT
if not handled then return end

local provider = {}
provider.name         = 'framework'
provider.capabilities = { playerBank = true, society = false }

-- ---------------------------------------------------------------------------
-- Player bank
-- sp.getMoney / sp.addMoney / sp.removeMoney are defined in the glob-loaded
-- server modules. Calling them here is safe because function bodies are
-- resolved at call time, not at file-load time.
-- ---------------------------------------------------------------------------

function provider.getPlayerBankBalance(source)
    if type(sp.getMoney) ~= 'function' then return 0 end
    local ok, val = pcall(sp.getMoney, source, 'bank')
    return (ok and type(val) == 'number') and val or 0
end

function provider.addPlayerBankMoney(source, amount, reason)
    if type(sp.addMoney) ~= 'function' then return false end
    local ok, result = pcall(sp.addMoney, source, 'bank', amount)
    return ok and result == true
end

function provider.removePlayerBankMoney(source, amount, reason)
    if type(sp.removeMoney) ~= 'function' then return false end
    local ok, result = pcall(sp.removeMoney, source, 'bank', amount)
    return ok and result == true
end

-- ---------------------------------------------------------------------------
-- Society  (not supported — capability.society = false)
-- The wrappers check capabilities before calling these; these are only here
-- as a safe fallback in case the wrapper skips the check.
-- ---------------------------------------------------------------------------

function provider.getSocietyBalance(accountId)        return 0   end
function provider.addSocietyMoney(accountId, amount, reason)    return false end
function provider.removeSocietyMoney(accountId, amount, reason) return false end

sp.bankProvider = provider
sp.print.info(('[banking] provider=%s playerBank=%s society=%s'):format(
    provider.name,
    tostring(provider.capabilities.playerBank),
    tostring(provider.capabilities.society)
))
