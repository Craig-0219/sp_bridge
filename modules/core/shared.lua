-- modules/core/shared.lua
-- Normalize schemas and utility functions shared across all sides

--- Default normalized money schema
function sp.defaultNormalizedMoney()
    return { cash = 0, bank = 0, black = nil }
end

--- Default normalized job schema
function sp.defaultNormalizedJob()
    return {
        name   = 'unemployed',
        label  = 'Unemployed',
        onduty = false,
        isBoss = false,
        grade  = { level = 0, name = 'recruit', label = 'Recruit', salary = nil }
    }
end

--- Default normalized player data schema
function sp.defaultNormalizedPlayerData()
    return {
        source      = nil,
        identifier  = nil,
        characterId = nil,
        name        = nil,
        job         = sp.defaultNormalizedJob(),
        gang        = nil,
        money       = sp.defaultNormalizedMoney(),
        metadata    = nil,
    }
end

--- Normalize an ESX job table into NormalizedJob
---@param job table  ESX job object (e.g. Player.job)
---@return table NormalizedJob
function sp.normalizeESXJob(job)
    if type(job) ~= 'table' then return sp.defaultNormalizedJob() end
    return {
        name   = job.name        or 'unemployed',
        label  = job.label       or 'Unemployed',
        onduty = true, -- ESX does not expose on-duty natively
        isBoss = (job.grade_name == 'boss'),
        grade  = {
            level  = job.grade        or 0,
            name   = job.grade_name   or 'recruit',
            label  = job.grade_label  or 'Recruit',
            salary = job.grade_salary or nil,
        }
    }
end

--- Normalize a QBCore job table into NormalizedJob
---@param job table  QBCore job object
---@return table NormalizedJob
function sp.normalizeQBJob(job)
    if type(job) ~= 'table' then return sp.defaultNormalizedJob() end
    local grade = type(job.grade) == 'table' and job.grade or {}
    return {
        name   = job.name   or 'unemployed',
        label  = job.label  or 'Unemployed',
        onduty = job.onduty == true,
        isBoss = job.isboss == true,
        grade  = {
            level  = grade.level   or 0,
            name   = grade.name    or 'recruit',
            label  = grade.label   or 'Recruit',
            salary = grade.payment or nil,
        }
    }
end

--- Normalize a QBOX job table into NormalizedJob (same schema as QB for now)
---@param job table  QBOX job object
---@return table NormalizedJob
function sp.normalizeQBOXJob(job)
    return sp.normalizeQBJob(job)
end

--- Normalize a QBCore gang table into NormalizedGang or nil
---@param gang table  QBCore gang object
---@return table|nil  NormalizedGang, nil if no active gang
function sp.normalizeQBGang(gang)
    if type(gang) ~= 'table' then return nil end
    if gang.name == 'none' or gang.name == nil then return nil end
    local grade = type(gang.grade) == 'table' and gang.grade or {}
    return {
        name   = gang.name,
        label  = gang.label or gang.name,
        isBoss = gang.isboss == true,
        grade  = {
            level = grade.level or 0,
            name  = grade.name  or 'recruit',
            label = grade.label or 'Recruit',
        }
    }
end

--- Normalize a QBOX gang table into NormalizedGang or nil
---@param gang table  QBOX gang object
---@return table|nil  NormalizedGang
function sp.normalizeQBOXGang(gang)
    return sp.normalizeQBGang(gang)
end
