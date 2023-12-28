-- Build a hierarchy of crafting machines, to be used with proper unlocking behaviour

crafting_tech_needed = {}
crafting_hierarchy = {}
crafting_machines = {}
crafting_entities = {}

for _, class_info in pairs(data.raw['recipe-category']) do
    crafting_hierarchy[class_info.name] = {}
    crafting_machines[class_info.name] = {}
end
for _, class_info in pairs(data.raw['resource-category']) do
    crafting_hierarchy[class_info.name] = {}
    crafting_machines[class_info.name] = {}
end

-- Gather all of the assembling machines for each type of crafting

all_machines = {}
for _, machine in pairs(data.raw['assembling-machine']) do
    if machine.crafting_categories and machine.name then
        table.insert(all_machines, machine)
    end
end
for _, machine in pairs(data.raw['rocket-silo']) do
    if machine.crafting_categories and machine.name then
        table.insert(all_machines, machine)
    end
end
for _, machine in pairs(data.raw['furnace']) do
    if machine.crafting_categories and machine.name then
        table.insert(all_machines, machine)
    end
end

for _, machine in pairs(all_machines) do
    crafting_entities[machine.name] = {}
    for _, category in pairs(machine.crafting_categories) do
        table.insert(crafting_entities[machine.name], category)
    end
end

-- Gather all mining drills for each type of crafting

for _, drill in pairs(data.raw['mining-drill']) do
    if drill.resource_categories and drill.name then
        crafting_entities[drill.name] = {}
        for _, category in pairs(drill.resource_categories) do
            table.insert(crafting_entities[drill.name], category)
        end
    end
end

-- Convert entities into items

machine_categories = {}

for _, item in pairs(data.raw.item) do
    if item.place_result and crafting_entities[item.place_result] then
        machine_categories[item.name] = {}
        for _, category in pairs(crafting_entities[item.place_result]) do
            crafting_machines[category][item.name] = true
            machine_categories[item.name][category] = true
        end
    end
end

hand_craft_possible = {}

-- Gather all categories that can be hand-crafted

for _, character in pairs(data.raw.character) do
    if character.crafting_categories then
        for _, category in pairs(character.crafting_categories) do
            hand_craft_possible[category] = true
        end
    end
end

for category, machines in pairs(crafting_machines) do
    log("Crafting category " .. category .. " can be made in following machines:")
    if hand_craft_possible[category] then
        log("    == Character ==")
    end
    for machine, _ in pairs(machines) do
        log("    " .. machine)
    end
end

-- Determine which technologies are required for each crafting class.
-- First, put all hand-crafted recipes
-- Second, for all remaining crafting categories, pick one with the least maximum 
--   of both the technology needed to craft a recipe and assembler technology needed for that. 
--   This will take --quadratic-- cubic time, because I don't wanna to write any priority queues.

-- But first, check all of the recipes and pick the earliest possible tech for each class that allows producing assemblers

for key, val in pairs(data.raw.recipe) do
    recipe_unlocking_tech = nil
    if unlocking_tech[key] then
        recipe_unlocking_tech = tech_order_reverse[unlocking_tech[key]]
    end
    if SciencePackGalore.isRecipeEnabledFromStart(val) then
        recipe_unlocking_tech = 0
    end
    if recipe_unlocking_tech ~= nil then
        recipe_category = "crafting"
        if val.category then
            recipe_category = val.category
        end
        recipe_products = SciencePackGalore.getRecipeProducts(val)
        if recipe_products then
            for _, product in pairs(recipe_products) do
                if machine_categories[product] then
                    for category, _ in pairs(machine_categories[product]) do
                        if crafting_hierarchy[category][recipe_category] == nil or crafting_hierarchy[category][recipe_category] > recipe_unlocking_tech then
                            crafting_hierarchy[category][recipe_category] = recipe_unlocking_tech
                        end
                    end
                end
            end
        end
    end
end

-- Now, get that techs

for category, _ in pairs(hand_craft_possible) do
    crafting_tech_needed[category] = 0
end

something_changed = true

while something_changed do
    something_changed = false
    for category, crafts in pairs(crafting_hierarchy) do
        for required_category, required_tech in pairs(crafts) do
            if crafting_tech_needed[category] == nil then
                crafting_tech_needed[category] = required_tech
                something_changed = true
            end
            if crafting_tech_needed[required_category] ~= nil and crafting_tech_needed[category] > math.max(crafting_tech_needed[required_category], required_tech) then
                crafting_tech_needed[category] = math.max(crafting_tech_needed[required_category], required_tech)
                something_changed = true
            end
        end
    end
end

for category, required_tech in pairs(crafting_tech_needed) do
    if required_tech == 0 then
        log("Crafting category " .. category .. " can be accessed from the start.")
    else
        log("Crafting category " .. category .. " requires a technology " .. tech_order[required_tech] .. ".")
    end
end

-- Bump recipe requirements according to results

for key, val in pairs(data.raw.recipe) do
    recipe_unlocking_tech = nil
    if unlocking_tech[key] then
        recipe_unlocking_tech = tech_order_reverse[unlocking_tech[key]]
    end
    if SciencePackGalore.isRecipeEnabledFromStart(val) then
        recipe_unlocking_tech = 0
    end
    if recipe_unlocking_tech ~= nil then
        recipe_category = "crafting"
        if val.category then
            recipe_category = val.category
        end
        if crafting_tech_needed[recipe_category] == nil then
            unlocking_tech[key] = nil
            log("Recipe " .. key .. " is uncraftable due to the lack of capable assembling machines.")
        else 
            if crafting_tech_needed[recipe_category] > recipe_unlocking_tech then
                unlocking_tech[key] = tech_order[crafting_tech_needed[recipe_category]]
                log("Recipe " .. key .. " got requirements bumped to " .. unlocking_tech[key] .. " due to assembling machine requirements.")
            end
        end
    end
end