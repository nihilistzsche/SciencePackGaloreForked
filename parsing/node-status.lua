    -- Update the node data to take into account tech levels calculated in tree-ordering.
    -- For each node, we want to know at which tech level it becomes possible to produce said node "infinitely".
    -- By "infinite", I mean here making stuff without human input.
    -- The following nodes are banned:
    -- - energy: manual-mining
    -- - mining-category: any recipes with no prerequisites
    -- - recipe-category: any recipes with no prerequisites

    SciencePackGalore.min_level_to_produce_infinitely = {}
    SciencePackGalore.prereq_to_produce_infinitely = {}
    SciencePackGalore.min_level_ordering = {}

    local prototype_postrequisites = {}
    local prototype_dependency_count = {}

    for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
        local node_data = SciencePackGalore.reverse_prototype_internal_id[key]
        prototype_postrequisites[key] = {}
        prototype_dependency_count[key] = {}
        for prereq_key, prereq_val in pairs(val) do
            prototype_dependency_count[key][prereq_key] = 1 -- block stuff before it is unlocked via tech level progression
            if node_data.type == 'energy' and node_data.name == 'manual-mining' then
                prototype_dependency_count[key][prereq_key] = prototype_dependency_count[key][prereq_key] + 1 -- fake dependency to always ignore them
            end
            if (node_data.type == 'mining-category' or node_data.type == 'recipe-category') and SciencePackGalore.tableSize(prereq_val.nodes) == 0 then
                prototype_dependency_count[key][prereq_key] = prototype_dependency_count[key][prereq_key] + 1 -- fake dependency to always ignore them
            end
            for _, node in pairs(prereq_val.nodes) do
                if node.coefficient > 0 then
                    prototype_dependency_count[key][prereq_key] = prototype_dependency_count[key][prereq_key] + 1
                end
            end
        end
    end

    for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
        for prereq_key, prereq_val in pairs(val) do
            for _, node in pairs(prereq_val.nodes) do
                if node.coefficient > 0 then
                    local node_id = SciencePackGalore.getEntityID(node)
                    if node_id then
                        table.insert(prototype_postrequisites[node_id], { key, prereq_key }) 
                    end
                end
            end
        end
    end

    local queue = {}
    local start_id = 1
    local end_id = 1


    for current_level, new_item in pairs(SciencePackGalore.tree_ordering) do
        local new_item_id = SciencePackGalore.getEntityID(new_item)

        for prereq_key, prereq_val in pairs(prototype_dependency_count[new_item_id]) do
            if prereq_val == 1 then
                if not SciencePackGalore.min_level_to_produce_infinitely[new_item_id] then
                    queue[end_id] = new_item_id
                    SciencePackGalore.min_level_to_produce_infinitely[new_item_id] = current_level
                    SciencePackGalore.prereq_to_produce_infinitely[new_item_id] = prereq_key
                    table.insert(SciencePackGalore.min_level_ordering, new_item)
                    local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[new_item_id][prereq_key])
                    SciencePackGalore.entity_full_cost[new_item_id] = cost_structure.cost
                    SciencePackGalore.entity_energy_cost[new_item_id] = cost_structure.energy
                    end_id = end_id + 1
                end
            end
            prototype_dependency_count[new_item_id][prereq_key] = prototype_dependency_count[new_item_id][prereq_key] - 1
        end

        while start_id < end_id do
            local current_item = queue[start_id]
            start_id = start_id + 1
            for _, dep in pairs(prototype_postrequisites[current_item]) do
                prototype_dependency_count[dep[1]][dep[2]] = prototype_dependency_count[dep[1]][dep[2]] - 1
                if prototype_dependency_count[dep[1]][dep[2]] == 0 then
                    if not SciencePackGalore.min_level_to_produce_infinitely[dep[1]] then
                        queue[end_id] = dep[1]
                        SciencePackGalore.min_level_to_produce_infinitely[dep[1]] = current_level
                        SciencePackGalore.prereq_to_produce_infinitely[dep[1]] = dep[2]
                        table.insert(SciencePackGalore.min_level_ordering, SciencePackGalore.reverse_prototype_internal_id[dep[1]])
                        local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[dep[1]][dep[2]])
                        SciencePackGalore.entity_full_cost[dep[1]] = cost_structure.cost
                        SciencePackGalore.entity_energy_cost[dep[1]] = cost_structure.energy
                        end_id = end_id + 1
                    end
                end
            end
        end
    end


    if enable_logging then
        for ind, val in pairs(SciencePackGalore.tree_ordering) do
            if val.type == 'item' then
                log("Item " .. val.name .. " has a total cost of " .. SciencePackGalore.entity_full_cost[SciencePackGalore.getEntityID(val)] .. ".")
            end
        end
    end
    --[[ 
    log("Science levels for sustainable production:")

    for ind, val in pairs(SciencePackGalore.tree_ordering) do
        if val.type == 'item' then
            if SciencePackGalore.min_level_to_produce_infinitely[SciencePackGalore.getEntityID(val)] then
                log(val.name .. ": " .. SciencePackGalore.min_level_to_produce_infinitely[SciencePackGalore.getEntityID(val)])
            else
                log(val.name .. ": cannot")
            end
        end
    end
    ]]