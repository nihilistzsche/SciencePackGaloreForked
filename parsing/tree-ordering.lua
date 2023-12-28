    -- Do two passes through the tree. The first pass orders everything that is not dependent on unreachable stuff. The second pass orders the rest.

    SciencePackGalore.tree_ordering = {} -- contains type-name pairs
    SciencePackGalore.reverse_tree_ordering = {}
    SciencePackGalore.entity_full_cost = {}
    SciencePackGalore.entity_energy_cost = {}
    SciencePackGalore.picked_predecessor = {}

    local prototype_postrequisites = {}
    local prototype_dependency_count = {}

    for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
        prototype_postrequisites[key] = {}
        prototype_dependency_count[key] = {}
        for prereq_key, prereq_val in pairs(val) do
            prototype_dependency_count[key][prereq_key] = SciencePackGalore.tableSize(prereq_val.nodes)
        end
    end

    for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
        for prereq_key, prereq_val in pairs(val) do
            for _, node in pairs(prereq_val.nodes) do
                local node_id = SciencePackGalore.getEntityID(node)
                if node_id then
                    table.insert(prototype_postrequisites[node_id], { key, prereq_key }) 
                end
            end
        end
    end

    local queue = {}
    local start_id = 1
    local end_id = 1

    for key, val in pairs(prototype_dependency_count) do
        for prereq_key, prereq_val in pairs(val) do
            if prereq_val == 0 then
                if not SciencePackGalore.reverse_tree_ordering[key] then
                    queue[end_id] = key
                    SciencePackGalore.tree_ordering[end_id] = SciencePackGalore.reverse_prototype_internal_id[key]
                    SciencePackGalore.reverse_tree_ordering[key] = end_id
                    SciencePackGalore.picked_predecessor[key] = prereq_key
                    local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[key][prereq_key])
                    SciencePackGalore.entity_full_cost[key] = cost_structure.cost
                    SciencePackGalore.entity_energy_cost[key] = cost_structure.energy
                    end_id = end_id + 1
                end
            end
        end
    end

    while start_id < end_id do
        local current_item = queue[start_id]
        start_id = start_id + 1
        for _, dep in pairs(prototype_postrequisites[current_item]) do
            prototype_dependency_count[dep[1]][dep[2]] = prototype_dependency_count[dep[1]][dep[2]] - 1
            if prototype_dependency_count[dep[1]][dep[2]] == 0 then
                if not SciencePackGalore.reverse_tree_ordering[dep[1]] then
                    queue[end_id] = dep[1]
                    SciencePackGalore.tree_ordering[end_id] = SciencePackGalore.reverse_prototype_internal_id[dep[1]]
                    SciencePackGalore.reverse_tree_ordering[dep[1]] = end_id
                    SciencePackGalore.picked_predecessor[dep[1]] = dep[2]
                    local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[dep[1]][dep[2]])
                    SciencePackGalore.entity_full_cost[dep[1]] = cost_structure.cost
                    SciencePackGalore.entity_energy_cost[dep[1]] = cost_structure.energy
                    end_id = end_id + 1
                end
            end
        end
    end

    SciencePackGalore.uncraftability_border = start_id

    -- End of the first pass.

    for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
        for prereq_key, prereq_val in pairs(val) do
            for _, node in pairs(prereq_val.nodes) do
                if SciencePackGalore.getEntityID(node) == nil then
                    prototype_dependency_count[key][prereq_key] = prototype_dependency_count[key][prereq_key] - 1
                    if prototype_dependency_count[key][prereq_key] == 0 then
                        if not SciencePackGalore.reverse_tree_ordering[key] then
                            queue[end_id] = key
                            SciencePackGalore.tree_ordering[end_id] = SciencePackGalore.reverse_prototype_internal_id[key]
                            SciencePackGalore.reverse_tree_ordering[key] = end_id
                            SciencePackGalore.picked_predecessor[key] = prereq_key
                            local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[key][prereq_key])
                            SciencePackGalore.entity_full_cost[key] = cost_structure.cost
                            SciencePackGalore.entity_energy_cost[key] = cost_structure.energy
                            end_id = end_id + 1
                        end
                    end
                end
            end
        end
    end

    while start_id < end_id do
        local current_item = queue[start_id]
        start_id = start_id + 1
        for _, dep in pairs(prototype_postrequisites[current_item]) do
            prototype_dependency_count[dep[1]][dep[2]] = prototype_dependency_count[dep[1]][dep[2]] - 1
            if prototype_dependency_count[dep[1]][dep[2]] == 0 then
                if not SciencePackGalore.reverse_tree_ordering[dep[1]] then
                    queue[end_id] = dep[1]
                    SciencePackGalore.tree_ordering[end_id] = SciencePackGalore.reverse_prototype_internal_id[dep[1]]
                    SciencePackGalore.reverse_tree_ordering[dep[1]] = end_id
                    local cost_structure = SciencePackGalore.getTotalEntityCost(SciencePackGalore.prototype_prerequisites[dep[1]][dep[2]])
                    SciencePackGalore.entity_full_cost[dep[1]] = cost_structure.cost
                    SciencePackGalore.picked_predecessor[dep[1]] = dep[2]
                    SciencePackGalore.entity_energy_cost[dep[1]] = cost_structure.energy
                    end_id = end_id + 1
                end
            end
        end
    end

    -- End of the second pass

    -- log(serpent.block(SciencePackGalore.tree_ordering))
    -- log(serpent.block(SciencePackGalore.entity_full_cost))
    -- log(serpent.block(SciencePackGalore.picked_predecessor))