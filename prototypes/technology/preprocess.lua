tech_order = {}
tech_order_reverse = {}

local postrequisites = {}
local prereqs_need = {}
local start_pos = 1
local end_pos = 1

log("There are " .. SciencePackGalore.tableSize(data.raw.technology) .. " technologies in total.")

-- Build a map of valid techs

valid_techs = {}

for key, val in pairs(data.raw.technology) do
    valid_techs[key] = SciencePackGalore.techIsValid(val)
end

-- Find all techs without prerequisites
-- Also, put postrequisites

for key, val in pairs(data.raw.technology) do
    if SciencePackGalore.techIsValid(val) then
        if not val.prerequisites or SciencePackGalore.tableSize(val.prerequisites) == 0 then
            log("Technology " .. key .. " has no prerequisites.")
            tech_order[end_pos] = key
            tech_order_reverse[key] = end_pos
            end_pos = end_pos + 1
        else
            prereqs_need[key] = SciencePackGalore.tableSize(val.prerequisites)
            for _, prereq in pairs(val.prerequisites) do
                log("Technology " .. key .. " has a prerequisite " .. prereq .. ".")
                if not postrequisites[prereq] then postrequisites[prereq] = {} end
                table.insert(postrequisites[prereq], key)
            end
        end
    end
end

-- Walk through the tech queue, compiling the proper order

while start_pos < end_pos do
    local cur_tech = tech_order[start_pos]
    log("Technology #" .. start_pos .. ": " .. cur_tech .. ".")
    start_pos = start_pos + 1
    if postrequisites[cur_tech] then
        for _, key in pairs(postrequisites[cur_tech]) do
            prereqs_need[key] = prereqs_need[key] - 1
            if prereqs_need[key] == 0 then
                tech_order[end_pos] = key
                tech_order_reverse[key] = end_pos
                end_pos = end_pos + 1
            end
        end
    end
end

log("All technologies below might be unreachable.")

-- Remove all invalid tech prerequisites and try again

for key, val in pairs(data.raw.technology) do
    if SciencePackGalore.techIsValid(val) and not tech_order_reverse[key] then
        if val.prerequisites then
            for _, prereq in pairs(val.prerequisites) do
                if not valid_techs[prereq] then
                    log("The prerequisite " .. prereq .. " of the technology " .. key .. " is disabled.")
                    prereqs_need[key] = prereqs_need[key] - 1
                    if prereqs_need[key] == 0 then
                        tech_order[end_pos] = key
                        tech_order_reverse[key] = end_pos
                        end_pos = end_pos + 1
                    end
                end
            end
        end
    end
end

while start_pos < end_pos do
    local cur_tech = tech_order[start_pos]
    log("Technology #" .. start_pos .. ": " .. cur_tech .. ".")
    start_pos = start_pos + 1
    if postrequisites[cur_tech] then
        for _, key in pairs(postrequisites[cur_tech]) do
            prereqs_need[key] = prereqs_need[key] - 1
            if prereqs_need[key] == 0 then
                tech_order[end_pos] = key
                tech_order_reverse[key] = end_pos
                end_pos = end_pos + 1
            end
        end
    end
end