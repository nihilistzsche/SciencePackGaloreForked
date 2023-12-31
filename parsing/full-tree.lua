    -- Things included in the tree:
    --  technology. Prereqs: labs that can fit all of the packs, the packs themselves and prereq technologies (in each possible case).
    --  entities. Prereqs: items that create those entities and necessary fuel categories.
    --  items. Prereqs: recipes that create those items.
    --  fluids. Prereqs: recipes that create those fluids + offshore pump, if exists.
    --  resources. Prereqs: things that can mine them.
    --  recipes. Prereqs: tech that unlocks the recipe and all of the recipe components, as well as recipe crafting category.
    --  crafting categories/mining categories/fuel category. Prereqs: entities/items included in each category.

    SciencePackGalore.prototype_internal_id = {technology = {}, lab = {}, energy = {}, item = {}, resource = {}, fluid = {}, ["offshore-pump"] = {}, entity = {}, recipe = {}, boiler = {}, ["recipe-category"] = {}, ["fuel-category"] = {}, ["resource-category"] = {}, ["mining-category"] = {}, ["crafting-machine"] = {}, ["fixed-recipe"] = {}, ["mining-drill"] = {}, rocket = {}}
    SciencePackGalore.reverse_prototype_internal_id = {}
    SciencePackGalore.prototype_prerequisites = {}

    -- Prerequisites format:
    --  nodes: table of pairs (node, coefficient) -- dependency and coefficient for cost calculation
    --  multiplier: how many items are produced by the requirements
    --  craft_time: only for recipes. Gets modified by the energy requirement of an assembler (the sum of energy requirements in input)
    --  energy_requirement: only for entities and categories. Is divided by craft time.

    local last_id = 1

    -- Technologies
    for key, val in pairs(data.raw.technology) do 
        if SciencePackGalore.techIsValid(val) then
            local val_lnk = SciencePackGalore.getNormalVersion(val)
            SciencePackGalore.prototype_internal_id['technology'][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "technology", name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            local pack_count = val_lnk.unit.count
            if not pack_count then
                pack_count = 1000
            end
            local prereqs = {nodes = {}, multiplier = 1, craft_time = val_lnk.unit.time * pack_count}
            local packs_needed = {}
            if val_lnk.prerequisites then
                for _, prereq in pairs(val_lnk.prerequisites) do
                    table.insert(prereqs["nodes"], {type = "technology", name = prereq, coefficient = 1})
                end
            end
            if val_lnk.unit.ingredients then
                for _, ingredient in pairs(val_lnk.unit.ingredients) do
                    item_data = SciencePackGalore.getFullItemName(ingredient)
                    table.insert(packs_needed, item_data.name)
                    table.insert(prereqs["nodes"], {type = item_data.type, name = item_data.name, coefficient = pack_count * item_data.amount})
                end
            end

            -- Check which labs can actually research that
            for lab_key, lab_val in pairs(data.raw.lab) do
                local can_be_used = true
                lab_pack_map = {}
                for _, pack in pairs(lab_val.inputs) do
                    lab_pack_map[pack] = true
                end
                for _, pack in pairs(packs_needed) do
                    if not lab_pack_map[pack] then
                        can_be_used = false
                    end
                end
                if can_be_used then
                    local real_prereqs = SciencePackGalore.tableDeepcopy(prereqs)
                    table.insert(real_prereqs["nodes"], {type = "lab", name = lab_key, coefficient = 1})
                    table.insert(SciencePackGalore.prototype_prerequisites[last_id], real_prereqs)
                end
            end

            last_id = last_id + 1
        end
    end

    -- Labs
    local lab_default_prereqs = {}
    local lab_prereq_or_nodes = {}

    for key, val in pairs(data.raw.lab) do
        SciencePackGalore.prototype_internal_id['lab'][key] = last_id
        SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "lab", name = key}
        SciencePackGalore.prototype_prerequisites[last_id] = {}

        lab_default_prereqs[key] = {nodes = {}, multiplier = 1}
        if val.energy_source.type ~= "void" then
            lab_default_prereqs[key]["energy_requirement"] = SciencePackGalore.applyCraftingSpeed(SciencePackGalore.convertPowerToDouble(val.energy_usage), (val.researching_speed or 1))
        end

        -- Add energy type
        if val.energy_source.type == "burner" then
            if val.energy_source.fuel_category then
                table.insert(lab_default_prereqs[key].nodes, {type = "fuel-category", name = val.energy_source.fuel_category, coefficient = 0})
            end
            if val.energy_source.fuel_categories then
                lab_prereq_or_nodes[key] = {}
                for _, category in pairs(val.energy_source.fuel_categories) do
                    table.insert(lab_prereq_or_nodes[key], {type = "fuel-category", name = category, coefficient = 0})
                end
            end
        end

        if val.energy_source.type == "fluid" and val.energy_source.fluid_box.filter then
            table.insert(lab_default_prereqs[key].nodes, {type = "fluid", name = val.energy_source.fluid_box.filter, coefficient = 0})
        end

        -- Fake types to support electricity and heat unlocks
        if val.energy_source.type == "electric" or val.energy_source.type == "heat" then
            table.insert(lab_default_prereqs[key].nodes, {type = "energy", name = val.energy_source.type, coefficient = 0})
        end

        last_id = last_id + 1
    end
    -- Check all items that can be placed as labs
    for key, val in pairs(data.raw.item) do
        if val.place_result and lab_default_prereqs[val.place_result] then
            local lab_id = SciencePackGalore.prototype_internal_id['lab'][val.place_result]
            if lab_prereq_or_nodes[val.place_result] then
                for _, node in pairs(lab_prereq_or_nodes[val.place_result]) do
                    local nodes_copy = SciencePackGalore.tableDeepcopy(lab_default_prereqs[val.place_result])
                    table.insert(nodes_copy.nodes, node)
                    table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                    table.insert(SciencePackGalore.prototype_prerequisites[lab_id], nodes_copy)
                end
            else
                local nodes_copy = SciencePackGalore.tableDeepcopy(lab_default_prereqs[val.place_result])
                table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                table.insert(SciencePackGalore.prototype_prerequisites[lab_id], nodes_copy)
            end
        end
    end

    -- Fake energy types
    -- electric: requires power poles AND (burner generator OR generator)
    SciencePackGalore.prototype_internal_id['energy']['electric'] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "electric"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}
    table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = "energy", name = "power-pole", coefficient = 0}, {type = "energy", name = "burner-generator", coefficient = 0}}})
    table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = "energy", name = "power-pole", coefficient = 0}, {type = "energy", name = "generator", coefficient = 0}}})
    last_id = last_id + 1
    -- power-pole: requires any type of power pole
    SciencePackGalore.prototype_internal_id['energy']['power-pole'] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "power-pole"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}
    local power_poles = {}
    for key, val in pairs(data.raw['electric-pole']) do
        power_poles[key] = true
    end
    -- Check all items that can be placed as poles
    for key, val in pairs(data.raw.item) do
        if val.place_result and power_poles[val.place_result] then
            table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = val.type, name = key, coefficient = 0}}})
        end
    end
    last_id = last_id + 1
    -- burner-generator: requires any type of burner generator
    SciencePackGalore.prototype_internal_id['energy']['burner-generator'] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "burner-generator"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}
    local burner_generators = {}
    local burner_generator_categories = {}
    for key, val in pairs(data.raw['burner-generator']) do
        burner_generators[key] = true
        burner_generator_categories[key] = {}
        if val.burner.fuel_category then
            table.insert(burner_generator_categories[key], {type = "fuel-category", name = val.burner.fuel_category, coefficient = 0})
        end
        if val.burner.fuel_categories then
            lab_prereq_or_nodes[key] = {}
            for _, category in pairs(val.burner.fuel_categories) do
                table.insert(burner_generator_categories[key], {type = "fuel-category", name = category, coefficient = 0})
            end
        end
    end
    -- Check all items that can be placed as burner generators 
    for key, val in pairs(data.raw.item) do
        if val.place_result and burner_generators[val.place_result] then
            for _, node in pairs(burner_generator_categories[val.place_result]) do
                table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = val.type, name = key, coefficient = 0}, SciencePackGalore.tableDeepcopy(node)}})
            end
        end
    end
    last_id = last_id + 1
    -- generator: requires any type of generator
    SciencePackGalore.prototype_internal_id['energy']['generator'] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "generator"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}
    local fluid_generators = {}
    local fluid_generator_fluids = {}
    for key, val in pairs(data.raw['generator']) do
        fluid_generators[key] = true
        if val.fluid_box.filter then
            fluid_generator_fluids[key] = {type = "fluid", name = val.fluid_box.filter, coefficient = 0}
        end
    end
    -- Check all items that can be placed as generators 
    for key, val in pairs(data.raw.item) do
        if val.place_result and fluid_generators[val.place_result] then
            if fluid_generator_fluids[val.place_result] then
                table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = val.type, name = key, coefficient = 0}, SciencePackGalore.tableDeepcopy(fluid_generator_fluids[val.place_result])}})
            else
                table.insert(SciencePackGalore.prototype_prerequisites[last_id], {multiplier = 1, nodes = {{type = val.type, name = key, coefficient = 0}}})
            end
        end
    end
    last_id = last_id + 1
    -- heat: requires heat source
    SciencePackGalore.prototype_internal_id['energy']['heat'] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "heat"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}
    local heat_default_prereqs = {}
    local heat_prereq_or_nodes = {}
    for key, val in pairs(data.raw.reactor) do
        heat_default_prereqs[key] = {nodes = {}, multiplier = 1}

        -- Add energy type
        if val.energy_source.type == "burner" then
            if val.energy_source.fuel_category then
                table.insert(heat_default_prereqs[key].nodes, {type = "fuel-category", name = val.energy_source.fuel_category, coefficient = 0})
            end
            if val.energy_source.fuel_categories then
                heat_prereq_or_nodes[key] = {}
                for _, category in pairs(val.energy_source.fuel_categories) do
                    table.insert(heat_prereq_or_nodes[key], {type = "fuel-category", name = category, coefficient = 0})
                end
            end
        end

        if val.energy_source.type == "fluid" and val.energy_source.fluid_box.filter then
            table.insert(heat_default_prereqs[key].nodes, {type = "fluid", name = val.energy_source.fluid_box.filter, coefficient = 0})
        end

        -- Fake types to support electricity and heat unlocks
        if val.energy_source.type == "electric" or val.energy_source.type == "heat" then
            table.insert(heat_default_prereqs[key].nodes, {type = "energy", name = val.energy_source.type, coefficient = 0})
        end
    end
    -- Check all items that can be placed as heat sources
    for key, val in pairs(data.raw.item) do
        if val.place_result and heat_default_prereqs[val.place_result] then
            if heat_prereq_or_nodes[val.place_result] then
                for _, node in pairs(heat_prereq_or_nodes[val.place_result]) do
                    local nodes_copy = SciencePackGalore.tableDeepcopy(heat_default_prereqs[val.place_result])
                    table.insert(nodes_copy.nodes, node)
                    table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                    table.insert(SciencePackGalore.prototype_prerequisites[last_id], nodes_copy)
                end
            else
                local nodes_copy = SciencePackGalore.tableDeepcopy(heat_default_prereqs[val.place_result])
                table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                table.insert(SciencePackGalore.prototype_prerequisites[last_id], nodes_copy)
            end
        end
    end
    last_id = last_id + 1

    local item_stack_size = {}

    -- Items (just names, all links are external)
    for _, category in pairs(item_prototype_classes) do
        for key, val in pairs(data.raw[category]) do
            SciencePackGalore.prototype_internal_id['item'][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "item", name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            item_stack_size[key] = val.stack_size

            last_id = last_id + 1
        end
    end
    -- Fluids (just names, all links are external)
    for key, val in pairs(data.raw.fluid) do
        SciencePackGalore.prototype_internal_id['fluid'][key] = last_id
        SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "fluid", name = key}
        SciencePackGalore.prototype_prerequisites[last_id] = {}
        last_id = last_id + 1
    end
    -- Link the burned stuff
    for key, val in pairs(data.raw.item) do
        if val.burnt_result then
            table.insert(SciencePackGalore.prototype_prerequisites[SciencePackGalore.prototype_internal_id['item'][val.burnt_result]], {nodes = {{type = "item", name = key, coefficient = 1}}, multiplier = 1})
        end
    end

    -- Resources (only autoplace-able and minable)
    for key, val in pairs(data.raw.resource) do
        if (val.autoplace or SciencePackGalore.resource_whitelist[key]) and val.minable then
            SciencePackGalore.prototype_internal_id['resource'][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "resource", name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            local resource_category = "basic-solid"
            if val.category then
                resource_category = val.category
            end

            local mining_time = val.minable.mining_time

            local prereqs = {craft_time = mining_time, multiplier = 1, nodes = {}}
            if (val.minable.fluid_amount or 0) > 0 then
                table.insert(prereqs.nodes, {type = "resource-category", name = resource_category, coefficient = 1})
                table.insert(prereqs.nodes, {type = "fluid", name = val.minable.required_fluid, coefficient = tonumber(val.minable.fluid_amount)})
            else
                table.insert(prereqs.nodes, {type = "mining-category", name = resource_category, coefficient = 1})
            end

            table.insert(SciencePackGalore.prototype_prerequisites[last_id], prereqs)

            -- Allow to produce items in minable results section
            if val.minable.results then
                for _, result in pairs(val.minable.results) do
                    local product = SciencePackGalore.getFullItemName(result)
                    if not product.amount then
                        product.amount = (result.amount_min + result.amount_max) / 2.0
                    end
                    if product.probability then
                        product.amount = product.amount * product.probability
                    end
                    local product_id = SciencePackGalore.getEntityID(product)
                    if product_id then
                        if product.type == "fluid" and (val.minable.fluid_amount or 0) == 0 then
                            table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "resource-category", name = resource_category, coefficient = 1}, {type = "resource", name = key, coefficient = 1}}, multiplier = product.amount, craft_time = SciencePackGalore.raw_resource_cost / SciencePackGalore.time_cost})
                        else
                            table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "resource", name = key, coefficient = 1}}, multiplier = product.amount, craft_time = SciencePackGalore.raw_resource_cost / SciencePackGalore.time_cost})
                        end
                    end
                end
            else
                if val.minable.result then
                    local product = {type = "item", name = val.minable.result, amount = (val.minable.count or 1)}
                    local product_id = SciencePackGalore.getEntityID(product)
                    if product_id then
                        table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "resource", name = key, coefficient = 1}}, multiplier = product.amount, craft_time = SciencePackGalore.raw_resource_cost / SciencePackGalore.time_cost})
                    end
                end
            end

            last_id = last_id + 1
        end
    end

    -- Offshore pumps
    local offshore_pump_default_prereqs = {}

    for key, val in pairs(data.raw["offshore-pump"]) do
        SciencePackGalore.prototype_internal_id['offshore-pump'][key] = last_id
        SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "offshore-pump", name = key}
        SciencePackGalore.prototype_prerequisites[last_id] = {}

        offshore_pump_default_prereqs[key] = {nodes = {}, multiplier = 1}

        local product = {type = "fluid", name = val.fluid}
        local product_id = SciencePackGalore.getEntityID(product)
        if product_id then
            table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "offshore-pump", name = key, coefficient = 0}}, multiplier = val.pumping_speed * 60, craft_time = 1})
        end

        last_id = last_id + 1
    end
    -- Check all items that can be placed as offshore pumps
    for key, val in pairs(data.raw.item) do
        if val.place_result and offshore_pump_default_prereqs[val.place_result] then
            local offshore_pump_id = SciencePackGalore.prototype_internal_id['offshore-pump'][val.place_result]
            local nodes_copy = SciencePackGalore.tableDeepcopy(offshore_pump_default_prereqs[val.place_result])
            table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 1})
            table.insert(SciencePackGalore.prototype_prerequisites[offshore_pump_id], nodes_copy)
        end
    end

    -- Entities. Check a lot of them
    for _, entity_class in pairs({"unit-spawner", "fish", "simple-entity", "tree"}) do
        for key, val in pairs(data.raw[entity_class]) do
            if val.minable and val.autoplace and (val.minable.fluid_amount or 0) == 0 then -- generates and can be mined
                -- check tags
                local tags_ok = true
                if val.flags then
                    for _, tag in pairs(val.flags) do
                        if tag == "player-creation" then
                            tags_ok = false
                        end
                    end
                end

                if tags_ok then
                    SciencePackGalore.prototype_internal_id['entity'][key] = last_id
                    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "entity", name = key}
                    SciencePackGalore.prototype_prerequisites[last_id] = {}

                    local mining_time = val.minable.mining_time
                    if val.autoplace.has_starting_area_placement then
                        mining_time = mining_time * SciencePackGalore.starting_cost_modifier
                    end

                    local prereqs = {craft_time = mining_time, multiplier = 1, nodes = {{type = "energy", name = "manual-mining", coefficient = 1}}} -- a fake node for manual mining
                    table.insert(SciencePackGalore.prototype_prerequisites[last_id], prereqs)

                    -- Allow to produce items in minable results section
                    if val.minable.results then
                        for _, result in pairs(val.minable.results) do
                            local product = SciencePackGalore.getFullItemName(result)
                            if not product.amount then
                                product.amount = (result.amount_min + result.amount_max) / 2.0
                            end
                            if product.probability then
                                product.amount = product.amount * product.probability
                            end
                            local product_id = SciencePackGalore.getEntityID(product)
                            if product_id then
                                if product.type == "item" then
                                    table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "entity", name = key, coefficient = 1}}, multiplier = product.amount, craft_time = SciencePackGalore.entity_cost / SciencePackGalore.time_cost})
                                end
                            end
                        end
                    else
                        if val.minable.result then
                            local product = {type = "item", name = val.minable.result, amount = (val.minable.count or 1)}
                            local product_id = SciencePackGalore.getEntityID(product)
                            if product_id then
                                table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = "entity", name = key, coefficient = 1}}, multiplier = product.amount, craft_time = SciencePackGalore.entity_cost / SciencePackGalore.time_cost})
                            end
                        end
                    end

                    last_id = last_id + 1
                end
            end
        end
    end

    -- Recipes
    local recipe_default_prereqs = {}

    for key, val in pairs(data.raw['recipe']) do
        if val then
            local val_lnk = SciencePackGalore.getNormalVersion(val)
            SciencePackGalore.prototype_internal_id['recipe'][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "recipe", name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            local prereqs = {nodes = {}, multiplier = 1, craft_time = (val_lnk.energy_required or 1)}

            -- Recipe is dependent on:
            -- - all items/fluids that it requires
            -- - its crafting category
            -- - any of the techs that unlock it (in addition)

            for _, ingredient in pairs(val_lnk.ingredients) do
                local ingredient_name = SciencePackGalore.getFullItemName(ingredient)
                if ingredient_name then
                    table.insert(prereqs.nodes, {type = ingredient_name.type, name = ingredient_name.name, coefficient = tonumber(ingredient_name.amount)})
                end
            end

            table.insert(prereqs.nodes, {type = 'recipe-category', name = (val_lnk.category or 'crafting'), coefficient = 1})

            if SciencePackGalore.isRecipeEnabledFromStart(val) then
                local prereqs_copy = SciencePackGalore.tableDeepcopy(prereqs)
                table.insert(SciencePackGalore.prototype_prerequisites[last_id], prereqs_copy)
            end

            -- Create links to items that are crafted as a result
            for _, result in pairs(val_lnk.results or {{val_lnk.result, (val_lnk.result_count or 1)}}) do
                local result_name = SciencePackGalore.getFullItemName(result)
                if result_name then
                    if not result_name.amount then
                        result_name.amount = (result.amount_min + result.amount_max) / 2.0
                    end
                    if result_name.probability then
                        result_name.amount = result_name.amount * result_name.probability
                    end
                    local result_id = SciencePackGalore.getEntityID(result_name)
                    if result_id then
                        table.insert(SciencePackGalore.prototype_prerequisites[result_id], {multiplier = result_name.amount, nodes = {{type = 'recipe', name = key, coefficient = 1}}})
                    end
                end
            end

            recipe_default_prereqs[last_id] = prereqs

            last_id = last_id + 1
        end
    end
    -- Check all the techs that can produce recipes
    for key, val in pairs(data.raw.technology) do 
        if SciencePackGalore.techIsValid(val) then
            local val_lnk = SciencePackGalore.getNormalVersion(val)
            if val_lnk.effects then
                for _, effect in pairs(val_lnk.effects) do
                    if effect and effect.type == 'unlock-recipe' then
                        local recipe_id = SciencePackGalore.getEntityID({type = 'recipe', name = effect.recipe})
                        if recipe_id then
                            local prereqs_copy = SciencePackGalore.tableDeepcopy(recipe_default_prereqs[recipe_id])
                            table.insert(prereqs_copy.nodes, {type = 'technology', name = key, coefficient = 0})
                            table.insert(SciencePackGalore.prototype_prerequisites[recipe_id], prereqs_copy)
                        end
                    end
                end
            end
        end
    end 

    -- Boilers (for fluid conversion)
    local boiler_default_prereqs = {}
    local boiler_prereq_or_nodes = {}

    for key, val in pairs(data.raw.boiler) do
        SciencePackGalore.prototype_internal_id['boiler'][key] = last_id
        SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "boiler", name = key}
        SciencePackGalore.prototype_prerequisites[last_id] = {}

        boiler_default_prereqs[key] = {nodes = {}, multiplier = 1}
        if val.energy_source.type ~= "void" then
            boiler_default_prereqs[key]["energy_requirement"] = SciencePackGalore.convertPowerToDouble('30kW') -- heating stuff is complicated. That would have to do, since I don't want to be bothered with temperatures
        end

        -- Add required fluid
        if val.fluid_box.filter then
            table.insert(boiler_default_prereqs[key].nodes, {type = "fluid", name = val.fluid_box.filter, coefficient = 1})
        end

        -- Add energy type
        if val.energy_source.type == "burner" then
            if val.energy_source.fuel_category then
                table.insert(boiler_default_prereqs[key].nodes, {type = "fuel-category", name = val.energy_source.fuel_category, coefficient = 0})
            end
            if val.energy_source.fuel_categories then
                boiler_prereq_or_nodes[key] = {}
                for _, category in pairs(val.energy_source.fuel_categories) do
                    table.insert(boiler_prereq_or_nodes[key], {type = "fuel-category", name = category, coefficient = 0})
                end
            end
        end

        if val.energy_source.type == "fluid" and val.energy_source.fluid_box.filter then
            table.insert(boiler_default_prereqs[key].nodes, {type = "fluid", name = val.energy_source.fluid_box.filter, coefficient = 0})
        end

        -- Fake types to support electricity and heat unlocks
        if val.energy_source.type == "electric" or val.energy_source.type == "heat" then
            table.insert(boiler_default_prereqs[key].nodes, {type = "energy", name = val.energy_source.type, coefficient = 0})
        end

        -- Add the link for boiler product
        if val.output_fluid_box.filter then
            local output_fluid = {type = 'fluid', name = val.output_fluid_box.filter, amount = 1}
            local output_fluid_id = SciencePackGalore.getEntityID(output_fluid)
            if output_fluid_id then
                table.insert(SciencePackGalore.prototype_prerequisites[output_fluid_id], {multiplier = 1, craft_time = 1, nodes = {{type = 'boiler', name = key, coefficient = 1}}})
            end
        end

        last_id = last_id + 1
    end
    -- Check all items that can be placed as boilers
    for key, val in pairs(data.raw.item) do
        if val.place_result and boiler_default_prereqs[val.place_result] then
            local boiler_id = SciencePackGalore.prototype_internal_id['boiler'][val.place_result]
            if boiler_prereq_or_nodes[val.place_result] then
                for _, node in pairs(boiler_prereq_or_nodes[val.place_result]) do
                    local nodes_copy = SciencePackGalore.tableDeepcopy(boiler_default_prereqs[val.place_result])
                    table.insert(nodes_copy.nodes, node)
                    table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                    table.insert(SciencePackGalore.prototype_prerequisites[boiler_id], nodes_copy)
                end
            else
                local nodes_copy = SciencePackGalore.tableDeepcopy(boiler_default_prereqs[val.place_result])
                table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                table.insert(SciencePackGalore.prototype_prerequisites[boiler_id], nodes_copy)
            end
        end
    end

    -- Recipe categories, fuel categories, resource categories
    for _, category in pairs({"recipe-category", "fuel-category", "resource-category"}) do
        for key, val in pairs(data.raw[category]) do
            SciencePackGalore.prototype_internal_id[category][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = category, name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            last_id = last_id + 1

            if category == 'resource-category' then
                SciencePackGalore.prototype_internal_id['mining-category'][key] = last_id
                SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = 'mining-category', name = key}
                SciencePackGalore.prototype_prerequisites[last_id] = {{nodes = {{type = 'resource-category', name = key, coefficient = 1}}, multiplier = 1}}

                last_id = last_id + 1
            end
        end
    end

    -- Character crafting and mining categories
    for key, val in pairs(data.raw.character) do
        if val.crafting_categories then
            for _, crafting_category in pairs(val.crafting_categories) do
                local crafting_category_id = SciencePackGalore.getEntityID({type = 'recipe-category', name = crafting_category})
                if crafting_category_id then
                    table.insert(SciencePackGalore.prototype_prerequisites[crafting_category_id], {nodes = {}, multiplier = 1})
                end
            end
        end
        if val.mining_categories then
            for _, mining_category in pairs(val.mining_categories) do
                local mining_category_id = SciencePackGalore.getEntityID({type = 'mining-category', name = mining_category})
                if mining_category_id then
                    table.insert(SciencePackGalore.prototype_prerequisites[mining_category_id], {nodes = {}, multiplier = 1})
                end
            end
        end
    end

    -- Recipe category connections: assembling machines, furnaces and rocket silos
    local crafting_machine_default_prereqs = {}
    local crafting_machine_prereq_or_nodes = {}

    for _, category in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
        for key, val in pairs(data.raw[category]) do
            SciencePackGalore.prototype_internal_id["crafting-machine"][key] = last_id
            SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "crafting-machine", name = key}
            SciencePackGalore.prototype_prerequisites[last_id] = {}

            crafting_machine_default_prereqs[key] = {nodes = {}, multiplier = 1}
            if val.energy_source.type ~= "void" then
                crafting_machine_default_prereqs[key]["energy_requirement"] = SciencePackGalore.applyCraftingSpeed(SciencePackGalore.convertPowerToDouble(val.energy_usage), val.crafting_speed)
            end

            -- Add energy type
            if val.energy_source.type == "burner" then
                if val.energy_source.fuel_category then
                    table.insert(crafting_machine_default_prereqs[key].nodes, {type = "fuel-category", name = val.energy_source.fuel_category, coefficient = 0})
                end
                if val.energy_source.fuel_categories then
                    crafting_machine_prereq_or_nodes[key] = {}
                    for _, burner_category in pairs(val.energy_source.fuel_categories) do
                        table.insert(crafting_machine_prereq_or_nodes[key], {type = "fuel-category", name = burner_category, coefficient = 0})
                    end
                end
            end

            if val.energy_source.type == "fluid" and val.energy_source.fluid_box.filter then
                table.insert(crafting_machine_default_prereqs[key].nodes, {type = "fluid", name = val.energy_source.fluid_box.filter, coefficient = 0})
            end

            -- Fake types to support electricity and heat unlocks
            if val.energy_source.type == "electric" or val.energy_source.type == "heat" then
                table.insert(crafting_machine_default_prereqs[key].nodes, {type = "energy", name = val.energy_source.type, coefficient = 0})
            end

            -- Stuff with fixed recipes: they work a bit differently
            if val.fixed_recipe then
                local fixed_recipe_id = SciencePackGalore.getEntityID({type = 'fixed-recipe', name = val.fixed_recipe})
                if fixed_recipe_id == nil then
                    last_id = last_id + 1
                    fixed_recipe_id = last_id
                    SciencePackGalore.prototype_internal_id["fixed-recipe"][val.fixed_recipe] = last_id
                    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "fixed-recipe", name = val.fixed_recipe}
                    SciencePackGalore.prototype_prerequisites[last_id] = {}

                    local recipe_id = SciencePackGalore.getEntityID({type = 'recipe', name = val.fixed_recipe})
                    if recipe_id then
                        local recipe_prototype_copy = SciencePackGalore.tableDeepcopy(SciencePackGalore.prototype_prerequisites[recipe_id])
                        for _, prereq_bunch in pairs(recipe_prototype_copy) do
                            for _, prereq in pairs(prereq_bunch.nodes) do
                                if prereq.type == 'recipe-category' then
                                    prereq.type = 'fixed-recipe'
                                    prereq.name = val.fixed_recipe
                                end
                            end
                            table.insert(SciencePackGalore.prototype_prerequisites[recipe_id], prereq_bunch)
                        end
                    end
                end
                table.insert(SciencePackGalore.prototype_prerequisites[fixed_recipe_id], {nodes = {{type = 'crafting-machine', name = key, coefficient = 1}}, multiplier = 1})
            else
                for _, crafting_category in pairs(val.crafting_categories) do
                    local crafting_category_id = SciencePackGalore.getEntityID({type = 'recipe-category', name = crafting_category})
                    if crafting_category_id then
                        table.insert(SciencePackGalore.prototype_prerequisites[crafting_category_id], {nodes = {{type = 'crafting-machine', name = key, coefficient = 1}}, multiplier = 1})
                    end
                end
            end

            last_id = last_id + 1
        end
    end
    -- Check all items that can be placed as crafting machines
    for key, val in pairs(data.raw.item) do
        if val.place_result and crafting_machine_default_prereqs[val.place_result] then
            local crafting_machine_id = SciencePackGalore.prototype_internal_id['crafting-machine'][val.place_result]
            if crafting_machine_prereq_or_nodes[val.place_result] then
                for _, node in pairs(crafting_machine_prereq_or_nodes[val.place_result]) do
                    local nodes_copy = SciencePackGalore.tableDeepcopy(crafting_machine_default_prereqs[val.place_result])
                    table.insert(nodes_copy.nodes, node)
                    table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                    table.insert(SciencePackGalore.prototype_prerequisites[crafting_machine_id], nodes_copy)
                end
            else
                local nodes_copy = SciencePackGalore.tableDeepcopy(crafting_machine_default_prereqs[val.place_result])
                table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                table.insert(SciencePackGalore.prototype_prerequisites[crafting_machine_id], nodes_copy)
            end
        end
    end

    -- Fuel category connections: iterate over items
    for _, category in pairs(item_prototype_classes) do
        for key, val in pairs(data.raw[category]) do
            if val.fuel_category then
                local fuel_category_id = SciencePackGalore.getEntityID({type = 'fuel-category', name = val.fuel_category})
                if fuel_category_id then
                    table.insert(SciencePackGalore.prototype_prerequisites[fuel_category_id], {nodes = {{type = 'item', name = key, coefficient = 0}}, multiplier = 1})
                end
            end
        end
    end

    -- Resource categories: mining drills and pumpjacks
    local mining_drill_default_prereqs = {}
    local mining_drill_prereq_or_nodes = {}

    for key, val in pairs(data.raw['mining-drill']) do
        SciencePackGalore.prototype_internal_id["mining-drill"][key] = last_id
        SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "mining-drill", name = key}
        SciencePackGalore.prototype_prerequisites[last_id] = {}

        mining_drill_default_prereqs[key] = {nodes = {}, multiplier = 1}

        if val.energy_source.type ~= "void" then
            mining_drill_default_prereqs[key]["energy_requirement"] = SciencePackGalore.applyCraftingSpeed(SciencePackGalore.convertPowerToDouble(val.energy_usage), val.mining_speed)
        end

        -- Add energy type
        if val.energy_source.type == "burner" then
            if val.energy_source.fuel_category then
                table.insert(mining_drill_default_prereqs[key].nodes, {type = "fuel-category", name = val.energy_source.fuel_category, coefficient = 0})
            end
            if val.energy_source.fuel_categories then
                mining_drill_prereq_or_nodes[key] = {}
                for _, burner_category in pairs(val.energy_source.fuel_categories) do
                    table.insert(mining_drill_prereq_or_nodes[key], {type = "fuel-category", name = burner_category, coefficient = 0})
                end
            end
        end

        if val.energy_source.type == "fluid" and val.energy_source.fluid_box.filter then
            table.insert(mining_drill_default_prereqs[key].nodes, {type = "fluid", name = val.energy_source.fluid_box.filter, coefficient = 0})
        end

        -- Fake types to support electricity and heat unlocks
        if val.energy_source.type == "electric" or val.energy_source.type == "heat" then
            table.insert(mining_drill_default_prereqs[key].nodes, {type = "energy", name = val.energy_source.type, coefficient = 0})
        end

        for _, resource_category in pairs(val.resource_categories) do
            local resource_category_id = SciencePackGalore.getEntityID({type = 'resource-category', name = resource_category})
            if resource_category_id then
                table.insert(SciencePackGalore.prototype_prerequisites[resource_category_id], {nodes = {{type = 'mining-drill', name = key, coefficient = 1}}, multiplier = 1})
            end
        end

        last_id = last_id + 1
    end
    -- Check all items that can be placed as mining drills
    for key, val in pairs(data.raw.item) do
        if val.place_result and mining_drill_default_prereqs[val.place_result] then
            local mining_drill_id = SciencePackGalore.prototype_internal_id['mining-drill'][val.place_result]
            if mining_drill_prereq_or_nodes[val.place_result] then
                for _, node in pairs(mining_drill_prereq_or_nodes[val.place_result]) do
                    local nodes_copy = SciencePackGalore.tableDeepcopy(mining_drill_default_prereqs[val.place_result])
                    table.insert(nodes_copy.nodes, node)
                    table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                    table.insert(SciencePackGalore.prototype_prerequisites[mining_drill_id], nodes_copy)
                end
            else
                local nodes_copy = SciencePackGalore.tableDeepcopy(mining_drill_default_prereqs[val.place_result])
                table.insert(nodes_copy.nodes, {type = val.type, name = key, coefficient = 0})
                table.insert(SciencePackGalore.prototype_prerequisites[mining_drill_id], nodes_copy)
            end
        end
    end

    -- Rocket launches
    SciencePackGalore.prototype_internal_id["rocket"]["rocket"] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "rocket", name = "rocket"}
    SciencePackGalore.prototype_prerequisites[last_id] = {}

    for key, val in pairs(data.raw['rocket-silo']) do
        if val.fixed_recipe and val.rocket_result_inventory_size then
            table.insert(SciencePackGalore.prototype_prerequisites[last_id], {nodes = {{type = 'recipe', name = val.fixed_recipe, coefficient = tonumber(val.rocket_parts_required)}}, multiplier = val.rocket_result_inventory_size})
        end
    end

    for _, category in pairs(item_prototype_classes) do
        for key, val in pairs(data.raw[category]) do
            if val.rocket_launch_product or val.rocket_launch_products then
                for _, launch_product in pairs(val.rocket_launch_products or {val.rocket_launch_product}) do
                    local product_data = SciencePackGalore.getFullItemName(launch_product)
                    if not product_data.amount then
                        product_data.amount = (product_data.amount_min + product_data.amount_max) / 2.0
                    end
                    if product_data.probability then
                        product_data.amount = product_data.amount * product_data.probability
                    end

                    -- Send a stack, get a stack
                    local launch_limit = math.min(item_stack_size[key], (item_stack_size[product_data.name] or 0) / product_data.amount)
                    
                    local product_id = SciencePackGalore.getEntityID(product_data)
                    if product_id then
                        table.insert(SciencePackGalore.prototype_prerequisites[product_id], {nodes = {{type = 'rocket', name = 'rocket', coefficient = 1}, {type = 'item', name = key, coefficient = launch_limit}}, multiplier = launch_limit * product_data.amount})
                    end
                end
            end
        end
    end

    last_id = last_id + 1

    -- Manual mining
    SciencePackGalore.prototype_internal_id["energy"]["manual-mining"] = last_id
    SciencePackGalore.reverse_prototype_internal_id[last_id] = {type = "energy", name = "manual-mining"}
    SciencePackGalore.prototype_prerequisites[last_id] = {{nodes = {}, multiplier = 1}}

    last_id = last_id + 1


    -- log(serpent.block(SciencePackGalore.prototype_internal_id))
    -- log(serpent.block(SciencePackGalore.prototype_prerequisites))

    -- Log everything
    if enable_logging then
        for key, val in pairs(SciencePackGalore.prototype_prerequisites) do
            log(SciencePackGalore.reverse_prototype_internal_id[key].type .. ":" .. SciencePackGalore.reverse_prototype_internal_id[key].name)
            for _, prereqs in pairs(val) do
                local result = "  x" .. prereqs.multiplier
                if prereqs.craft_time then
                    result = result .. " in " .. prereqs.craft_time .. "s"
                end
                if prereqs.energy_requirement then
                    result = result .. " for " .. prereqs.energy_requirement .. "W"
                end
                log(result)
                log("  Ingredients:")
                for _, node in pairs(prereqs.nodes) do
                    log("    " .. node.type .. ":" .. node.name .. " - x" .. node.coefficient)
                end
            end
        end
    end
