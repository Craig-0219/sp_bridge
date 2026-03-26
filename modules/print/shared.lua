sp.print = {}

local function printLog(type, message)
    local color = '^7'
    if type == 'success' then color = '^2'
    elseif type == 'error' then color = '^1'
    elseif type == 'warn' then color = '^3'
    elseif type == 'info' then color = '^5'
    end
    print(string.format('%s[%s] [%s] %s^7', color, sp.name, type:upper(), message))
end

function sp.print.success(message) printLog('success', message) end
function sp.print.error(message) printLog('error', message) end
function sp.print.warn(message) printLog('warn', message) end
function sp.print.info(message) printLog('info', message) end
