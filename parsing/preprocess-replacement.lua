-- preprocess.lua

tech_order = {}
tech_order_reverse = {}

local end_id = 1

for key, val in pairs(SciencePackGalore.tree_ordering) do
    if val.type == "technology" then
        table.insert(tech_order, val.name)
        tech_order_reverse[val.name] = end_id
        end_id = end_id + 1
    end
end

if enable_logging then
    log("There are " .. SciencePackGalore.tableSize(data.raw.technology) .. " technologies in total.")
    for key, val in pairs(tech_order) do
        log("Technology #" .. key .. ": " .. val .. ".")
    end
end

-- recipe-preprocess.lua, crafting-hierarchy.lua, item-preprocess.lua

item_techs = {}
base_items = {}

local overall_unlocking_tech = {}

for _, val in pairs(SciencePackGalore.min_level_ordering) do
    local key = SciencePackGalore.getEntityID(val)
    overall_unlocking_tech[key] = 0
    if val.type == "technology" then
        overall_unlocking_tech[key] = SciencePackGalore.reverse_tree_ordering[key]
    end
    for _, node in pairs(SciencePackGalore.prototype_prerequisites[key][SciencePackGalore.prereq_to_produce_infinitely[key]].nodes) do
        local node_id = SciencePackGalore.getEntityID(node)
        if node_id then
            if overall_unlocking_tech[node_id] then
                overall_unlocking_tech[key] = math.max(overall_unlocking_tech[key], overall_unlocking_tech[node_id])
            end
            if node.type == "technology" then
                overall_unlocking_tech[key] = math.max(overall_unlocking_tech[key], SciencePackGalore.reverse_tree_ordering[node_id])
            end
        end
    end
    if val.type == "item" then
        if overall_unlocking_tech[key] == 0 then
            base_items[val.name] = true
        else
            item_techs[val.name] = SciencePackGalore.tree_ordering[overall_unlocking_tech[key]].name
        end
    end
end

if enable_logging then
    for key, val in pairs(base_items) do
        log("Item " .. key .. " is available from the start.")
    end
    for key, val in pairs(item_techs) do
        log("Item " .. key .. " requires technology " .. val .. ".")
    end
end