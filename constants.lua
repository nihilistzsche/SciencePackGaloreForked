total_packs = 36

base_pack_time = 500 -- in ms
pack_time_increase = 100 -- in ms

enable_logging = false -- will still log important info

science_pack_ingredients = {
    {{type = "item", name = "iron-ore", amount = 1}, {type = "item", name = "copper-ore", amount = 1}},
    {{type = "item", name = "burner-inserter", amount = 2}, {type = "item", name = "splitter", amount = 1}},
    {{type = "item", name = "firearm-magazine", amount = 2}, {type = "item", name = "submachine-gun", amount = 1}},
    {{type = "item", name = "steel-plate", amount = 1}, {type = "item", name = "coal", amount = 2}},
    {{type = "item", name = "boiler", amount = 1}, {type = "item", name = "offshore-pump", amount = 1}, {type = "item", name = "small-lamp", amount = 2}},
    {{type = "item", name = "gun-turret", amount = 1}, {type = "item", name = "stone-wall", amount = 1}},
    {{type = "item", name = "steel-furnace", amount = 1}, {type = "item", name = "assembling-machine-2", amount = 1}},
    {{type = "item", name = "piercing-rounds-magazine", amount = 2}, {type = "item", name = "grenade", amount = 1}},
    {{type = "item", name = "fast-transport-belt", amount = 1}, {type = "item", name = "fast-inserter", amount = 1}},
    {{type = "item", name = "copper-cable", amount = 1}, {type = "item", name = "electronic-circuit", amount = 1}},
    {{type = "item", name = "medium-electric-pole", amount = 1}, {type = "item", name = "big-electric-pole", amount = 1}},
    {{type = "item", name = "rail", amount = 10}, {type = "item", name = "cargo-wagon", amount = 1}},
    {{type = "item", name = "car", amount = 1}, {type = "item", name = "concrete", amount = 50}},
    {{type = "item", name = "train-stop", amount = 1}, {type = "item", name = "rail-signal", amount = 2}, {type = "item", name = "rail-chain-signal", amount = 2}},
    {{type = "item", name = "sulfur", amount = 2}, {type = "item", name = "plastic-bar", amount = 2}},
    {{type = "item", name = "cliff-explosives", amount = 1}, {type = "item", name = "rocket", amount = 4}},
    {{type = "item", name = "solar-panel", amount = 1}, {type = "item", name = "accumulator", amount = 1}},
    {{type = "item", name = "bulk-inserter", amount = 2}},
    {{type = "item", name = "poison-capsule", amount = 1}, {type = "item", name = "slowdown-capsule", amount = 1}},
    {{type = "item", name = "modular-armor", amount = 1}, {type = "item", name = "solar-panel-equipment", amount = 4}},
    {{type = "item", name = "speed-module", amount = 1}, {type = "item", name = "efficiency-module", amount = 1}, {type = "item", name = "productivity-module", amount = 1}},
    {{type = "item", name = "tank", amount = 1}, {type = "item", name = "explosive-rocket", amount = 10}},
    {{type = "item", name = "laser-turret", amount = 1}, {type = "item", name = "defender-capsule", amount = 1}},
    {{type = "item", name = "rocket-fuel", amount = 3}, {type = "item", name = "low-density-structure", amount = 1}},
    {{type = "item", name = "assembling-machine-3", amount = 1}, {type = "item", name = "electric-engine-unit", amount = 6}},
    {{type = "item", name = "beacon", amount = 1}, {type = "item", name = "speed-module-2", amount = 1}, {type = "item", name = "efficiency-module-2", amount = 1}, {type = "item", name = "productivity-module-2", amount = 1}},
    {{type = "item", name = "express-transport-belt", amount = 4}, {type = "item", name = "express-splitter", amount = 1}},
    {{type = "item", name = "uranium-235", amount = 1}, {type = "item", name = "uranium-238", amount = 3}},
    {{type = "item", name = "roboport", amount = 1}, {type = "item", name = "construction-robot", amount = 10}},
    {{type = "item", name = "logistic-robot", amount = 2}, {type = "item", name = "passive-provider-chest", amount = 1}, {type = "item", name = "storage-chest", amount = 1}},
    {{type = "item", name = "cluster-grenade", amount = 1}, {type = "item", name = "piercing-shotgun-shell", amount = 3}},
    {{type = "item", name = "personal-roboport-equipment", amount = 1}, {type = "item", name = "power-armor", amount = 1}},
    {{type = "item", name = "destroyer-capsule", amount = 1}, {type = "item", name = "uranium-rounds-magazine", amount = 10}},
    {{type = "item", name = "artillery-turret", amount = 1}, {type = "item", name = "artillery-shell", amount = 1}},
    {{type = "item", name = "low-density-structure", amount = 2}, {type = "item", name = "rocket-fuel", amount = 1}},
    {{type = "item", name = "satellite", amount = 1}}
}

if mods["space-age"] then
    science_pack_ingredients[36] = {{type = "item", name = "carbon", amount = 1}, {type = "item", name = "ice", amount = 1}}
end

science_pack_yields = {
    4,
    30,
    30,
    4,
    12,
    20,
    30,
    10,
    5,
    1,
    6,
    20,
    15,
    5,
    1,
    8,
    6,
    10,
    2,
    50,
    10,
    30,
    10,
    2,
    15,
    75,
    10,
    45,
    30,
    5,
    4,
    70,
    20,
    10,
    3,
    200
}

max_random_selection_iterations = 30
item_prototype_classes = {"item", "ammo", "capsule", "gun", "module", "spidertron-remote", "tool", "armor", "repair-tool", "item-with-entity-data", "rail-planner", "selection-tool"}

SciencePackGalore.enable_random_craft_time = settings.startup[SciencePackGalore.prefix("randomize-craft-time")].value
SciencePackGalore.enable_random_pack_recipes = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes")].value

SciencePackGalore.first_pack_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-first-pack-cost")].value
SciencePackGalore.last_pack_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-last-pack-cost")].value

SciencePackGalore.energy_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-energy-cost")].value -- per J
SciencePackGalore.time_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-time-cost")].value -- per second
SciencePackGalore.raw_resource_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-raw-resource-cost")].value -- per raw resource
SciencePackGalore.entity_cost = SciencePackGalore.raw_resource_cost -- per entity
