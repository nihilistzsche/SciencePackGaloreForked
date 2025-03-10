SciencePackGalore = {}

function SciencePackGalore.prefix(name)
    return 'sem-spg_' .. name
end

function SciencePackGalore.toFixedString(num)
    return string.format("%03d", num)
end

function SciencePackGalore.tableSize(tbl)
    local tbl_len = 0
    for key, val in pairs(tbl) do
        tbl_len = tbl_len + 1
    end
    return tbl_len
end

function SciencePackGalore.tableDeepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local new_tbl = {}
    for key, val in pairs(tbl) do
        new_tbl[key] = SciencePackGalore.tableDeepcopy(val)
    end
    return new_tbl
end

function SciencePackGalore.techIsValid(tech)
    if not tech then
        return false
    end
    if tech.enabled ~= nil and tech.enabled == false then
        return false
    end
    if tech.hidden == true then
        return false
    end
    if tech.research_trigger then
        return false
    end
    return true
end

function SciencePackGalore.recursiveReplaceName(tbl, from, to)
    if tbl.name then
        if tbl.name == from then
            tbl.name = to
        end
    else
        for key, val in pairs(tbl) do
            SciencePackGalore.recursiveReplaceName(val, from, to)
        end
    end
end

function SciencePackGalore.recursiveMultiplyAmount(tbl, item, x)
    if tbl.name then
        if tbl.name == item then
            tbl.amount = math.max(1, math.floor(tbl.amount * x + 0.5))
        end
    else
        for key, val in pairs(tbl) do
            SciencePackGalore.recursiveMultiplyAmount(val, item, x)
        end
    end
end

function SciencePackGalore.getItemName(item_data)
    if item_data.name then
        return item_data.name
    end
    if item_data[1] then
        return item_data[1]
    end
    return nil
end

function SciencePackGalore.getFullItemName(item_data, default_type)
    default_type = default_type or "item"
    if item_data.name then
        local data_copy = table.deepcopy(item_data)
        if not data_copy.type then
            data_copy.type = default_type
        end
        return data_copy
    end
    if item_data[1] then
        return {type = default_type, name = item_data[1], amount = item_data[2]}
    end
    return nil
end

function SciencePackGalore.getRecipeProducts(recipe_data)
    local recipe_lnk = recipe_data
    if recipe_data.normal then
        recipe_lnk = recipe_data.normal
    else
        if recipe_data.expensive then
            recipe_lnk = recipe_data.expensive
        end
    end

    local banned_items = {}
    if recipe_lnk.ingredients then
        for _, ingredient in pairs(recipe_lnk.ingredients) do
            ingredient_name = SciencePackGalore.getItemName(ingredient)
            if ingredient_name then
                banned_items[ingredient_name] = true
            end
        end
    end

    local results = {}

    if recipe_lnk.result then
        if not banned_items[recipe_lnk.result] then
            table.insert(results, recipe_lnk.result)
        end
    end

    if recipe_lnk.results then
        for _, result in pairs(recipe_lnk.results) do
            result_name = SciencePackGalore.getItemName(result)
            if result_name and not banned_items[result_name] then
                table.insert(results, result_name)
            end
        end
    end

    return results
end

function SciencePackGalore.isRecipeEnabledFromStart(recipe_data)
    local recipe_lnk = recipe_data
    if recipe_data.normal then
        recipe_lnk = recipe_data.normal
    else
        if recipe_data.expensive then
            recipe_lnk = recipe_data.expensive
        end
    end

    if recipe_data.normal == false then
        return false
    end
    return (recipe_lnk.enabled ~= false)
end

function SciencePackGalore.getNormalVersion(thing)
    local thing_lnk = thing
    if thing.normal then
        thing_lnk = thing.normal
    else
        if thing.expensive then
            thing_lnk = thing.expensive
        end
    end
    return thing_lnk
end

function SciencePackGalore.getEntityID(node)
    if SciencePackGalore.prototype_internal_id[node.type] then
        if SciencePackGalore.prototype_internal_id[node.type][node.name] then
            return SciencePackGalore.prototype_internal_id[node.type][node.name]
        end
    end
    return nil
end

function SciencePackGalore.getTotalEntityCost(prereq)
    local total_cost = 0
    local total_energy = 0

    -- If entity requires energy, add this requirement
    if prereq.energy_requirement then
        total_energy = total_energy + prereq.energy_requirement
    end

    -- Sum up the costs of all requirements
    for _, node in pairs(prereq.nodes) do
        local node_id = SciencePackGalore.getEntityID(node)
        if node_id then
            if SciencePackGalore.entity_full_cost[node_id] then
                total_cost = total_cost + SciencePackGalore.entity_full_cost[node_id] * node.coefficient
            end
            if SciencePackGalore.entity_energy_cost[node_id] then
                total_energy = total_energy + SciencePackGalore.entity_energy_cost[node_id] * node.coefficient
            end
        end
    end

    -- If there is a time requirement, convert energy to cost
    if prereq.craft_time ~= nil then
        total_cost = total_cost + prereq.craft_time * SciencePackGalore.time_cost + prereq.craft_time * total_energy * SciencePackGalore.energy_cost
        total_energy = 0
    end

    -- Divide both costs by multiplier
    total_cost = total_cost / prereq.multiplier
    total_energy = total_energy / prereq.multiplier

    return {cost = total_cost, energy = total_energy}
end

function SciencePackGalore.convertPowerToDouble(power)
    -- kJ/kW
    if string.sub(power, -2, -2) == 'k' or string.sub(power, -2, -2) == 'K' then
        return 1e3 * tonumber(string.sub(power, 1, -3))
    end
    -- MJ/MW
    if string.sub(power, -2, -2) == 'M' then
        return 1e6 * tonumber(string.sub(power, 1, -3))
    end
    -- GJ/GW
    if string.sub(power, -2, -2) == 'G' then
        return 1e9 * tonumber(string.sub(power, 1, -3))
    end
    -- TJ/TW
    if string.sub(power, -2, -2) == 'T' then
        return 1e12 * tonumber(string.sub(power, 1, -3))
    end
    -- PJ/PW
    if string.sub(power, -2, -2) == 'P' then
        return 1e15 * tonumber(string.sub(power, 1, -3))
    end
    -- EJ/EW
    if string.sub(power, -2, -2) == 'E' then
        return 1e18 * tonumber(string.sub(power, 1, -3))
    end
    -- ZJ/ZW
    if string.sub(power, -2, -2) == 'Z' then
        return 1e21 * tonumber(string.sub(power, 1, -3))
    end
    -- YJ/YW
    if string.sub(power, -2, -2) == 'Y' then
        return 1e24 * tonumber(string.sub(power, 1, -3))
    end

    -- W/J
    return tonumber(string.sub(power, 1, -2))
end

function SciencePackGalore.applyCraftingSpeed(power, crafting_speed)
    local power_multiplier = SciencePackGalore.energy_cost / SciencePackGalore.time_cost
    -- Normal cost is time x (1 + power * power_multiplier)
    -- Then, crafting_speed x time x (1 + power * power_multiplier) = time x (1 + (crafting_speed - 1) + power * power_multiplier * crafting_speed)
    return power * crafting_speed + (1 / crafting_speed - 1) / power_multiplier
end

function SciencePackGalore.orderTwoItems(a, b)
    if not SciencePackGalore.min_level_to_produce_infinitely[a] and not SciencePackGalore.min_level_to_produce_infinitely[b] then
        return a < b
    end
    if not SciencePackGalore.min_level_to_produce_infinitely[a] then
        return false
    end
    if not SciencePackGalore.min_level_to_produce_infinitely[b] then
        return true
    end
    if SciencePackGalore.min_level_to_produce_infinitely[a] ~= SciencePackGalore.min_level_to_produce_infinitely[b] then
        return SciencePackGalore.min_level_to_produce_infinitely[a] < SciencePackGalore.min_level_to_produce_infinitely[b]
    end
    return a < b
end

function SciencePackGalore.stringStartsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function SciencePackGalore.roundToFirstDigit(num)
    local multiplier = 1
    while num > 10 do
        num = num / 10
        multiplier = multiplier * 10
    end
    return math.floor(num + 0.5) * multiplier
end