-- Tweaks for specific mods

-- Krastorio2
--    there is a wind turbine available from the start, which is not a normal generator.
--    creep collector collects biomass
if mods["Krastorio2"] then
    local entid = SciencePackGalore.getEntityID({type="energy", name="generator"})
    if entid then
        table.insert(SciencePackGalore.prototype_prerequisites[entid], {nodes = {}, multiplier = 1})
    end
    local entid = SciencePackGalore.getEntityID({type="item", name="biomass"})
    if entid then
        table.insert(SciencePackGalore.prototype_prerequisites[entid], {nodes = {{type="item", name="kr-creep-collector", coefficient=0}}, multiplier = 1, craft_time = 5})
    end
end

-- space-exploration
--    mining other planets requires a cargo rocket silo, cargo pods and cargo sections
--    mining vulcanite requires core miner (technically not, but...)
--    satellite produces 200 of satellite telemetry (this is only changed in Postprocess)
if mods["space-exploration"] then
    for _, resource in pairs({"se-water-ice", "se-methane-ice", "se-beryllium-ore", "se-cryonite", "se-holmium-ore", "se-vulcanite", "se-vitamelange"}) do
        local entid = SciencePackGalore.getEntityID({type="item", name=resource})
        if entid then
            for _, prereqs in pairs(SciencePackGalore.prototype_prerequisites[entid]) do
                if resource == "se-vulcanite" then
                    table.insert(prereqs.nodes, {type = "item", name = "se-core-miner", coefficient = 0})
                else
                    table.insert(prereqs.nodes, {type = "item", name = "se-rocket-launch-pad", coefficient = 0})
                    table.insert(prereqs.nodes, {type = "item", name = "se-cargo-rocket-cargo-pod", coefficient = 0})
                    table.insert(prereqs.nodes, {type = "item", name = "se-cargo-rocket-section", coefficient = 0})
                end
            end
        end
    end
    local entid = SciencePackGalore.getEntityID({type="item", name="se-satellite-telemetry"})
    if entid then
        table.insert(SciencePackGalore.prototype_prerequisites[entid], {nodes = {{type = "rocket", name = "rocket", coefficient = 1}, {type = "item", name = "satellite", coefficient = 1}}, multiplier = 200})
    end
end

-- IndustrialRevolution
--    wood & rubber wood have a positive feedback loop, requiring Forestry tech, Forestry crafting category and 50s per item
if mods['IndustrialRevolution'] then
    for _, resource in pairs({"wood", "rubber-wood"}) do
        local entid = SciencePackGalore.getEntityID({type="item", name=resource})
        table.insert(SciencePackGalore.prototype_prerequisites[entid], {nodes={{type="technology", name="ir2-bronze-forestry", coefficient=0}, {type="recipe-category", name="forestry", coefficient=1}}, craft_time=50, multiplier=1})
    end
end

-- angelsindustries
--    angels-main-lab-0 is always available
if mods['angelsindustries'] then
    local entid = SciencePackGalore.getEntityID({type="item", name="angels-main-lab-0"})
    if entid then
        table.insert(SciencePackGalore.prototype_prerequisites[entid], {nodes = {}, multiplier = 1})
    end
end

-- bobgreenhouse
--    wood has a positive feedback loop; to fix, will remove wood cost from bob-seedling recipe
if mods['bobgreenhouse'] then
    local entid = SciencePackGalore.getEntityID({type="recipe", name="bob-seedling"})
    if entid then
        for _, prereqs in pairs(SciencePackGalore.prototype_prerequisites[entid]) do
            local new_nodes = {}
            for _, node in pairs(prereqs.nodes) do
                if (node.type ~= "item" or node.name ~= "wood") then
                    table.insert(new_nodes, node)
                end
            end
            prereqs.nodes = new_nodes
        end
    end
end