SciencePackGalore.resource_whitelist = {}

-- IndustrialRevolution
--    some ores are placed in the control stage, fix their existence and results there
--    wood & rubber wood have a positive feedback loop, requiring Forestry tech, Forestry crafting category and 50s per item
if mods['IndustrialRevolution'] then
    for _, resource in pairs({"iron-gem-ore", "copper-gem-ore", "gold-gem-ore", "tin-gem-ore", "coal-gem-ore"}) do
        if data.raw.resource[resource] then
            SciencePackGalore.resource_whitelist[resource] = true
        end
    end
end