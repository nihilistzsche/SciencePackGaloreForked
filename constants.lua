total_packs = 36

base_pack_time = 500 -- in ms
pack_time_increase = 100 -- in ms

enable_logging = false -- will still log important info

science_pack_ingredients = {
    {{name = "iron-ore", amount = 1}, {name = "copper-ore", amount = 1}},
    {{name = "burner-inserter", amount = 2}, {name = "splitter", amount = 1}},
    {{name = "firearm-magazine", amount = 2}, {name = "submachine-gun", amount = 1}},
    {{name = "steel-plate", amount = 1}, {name = "coal", amount = 2}},
    {{name = "boiler", amount = 1}, {name = "offshore-pump", amount = 1}, {name = "small-lamp", amount = 2}},
    {{name = "gun-turret", amount = 1}, {name = "stone-wall", amount = 1}},
    {{name = "steel-furnace", amount = 1}, {name = "assembling-machine-2", amount = 1}},
    {{name = "piercing-rounds-magazine", amount = 2}, {name = "grenade", amount = 1}},
    {{name = "fast-transport-belt", amount = 1}, {name = "fast-inserter", amount = 1}},
    {{name = "red-wire", amount = 1}, {name = "green-wire", amount = 1}},
    {{name = "medium-electric-pole", amount = 1}, {name = "big-electric-pole", amount = 1}},
    {{name = "rail", amount = 10}, {name = "cargo-wagon", amount = 1}},
    {{name = "car", amount = 1}, {name = "concrete", amount = 50}},
    {{name = "train-stop", amount = 1}, {name = "rail-signal", amount = 2}, {name = "rail-chain-signal", amount = 2}},
    {{name = "sulfur", amount = 2}, {name = "plastic-bar", amount = 2}},
    {{name = "cliff-explosives", amount = 1}, {name = "rocket", amount = 4}},
    {{name = "solar-panel", amount = 1}, {name = "accumulator", amount = 1}},
    {{name = "stack-inserter", amount = 1}, {name = "stack-filter-inserter", amount = 1}},
    {{name = "poison-capsule", amount = 1}, {name = "slowdown-capsule", amount = 1}},
    {{name = "modular-armor", amount = 1}, {name = "solar-panel-equipment", amount = 4}},
    {{name = "speed-module", amount = 1}, {name = "effectivity-module", amount = 1}, {name = "productivity-module", amount = 1}},
    {{name = "tank", amount = 1}, {name = "explosive-rocket", amount = 10}},
    {{name = "laser-turret", amount = 1}, {name = "defender-capsule", amount = 1}},
    {{name = "rocket-fuel", amount = 3}, {name = "low-density-structure", amount = 1}},
    {{name = "assembling-machine-3", amount = 1}, {name = "electric-engine-unit", amount = 6}},
    {{name = "beacon", amount = 1}, {name = "speed-module-2", amount = 1}, {name = "effectivity-module-2", amount = 1}, {name = "productivity-module-2", amount = 1}},
    {{name = "express-transport-belt", amount = 4}, {name = "express-splitter", amount = 1}},
    {{name = "uranium-235", amount = 1}, {name = "uranium-238", amount = 3}},
    {{name = "roboport", amount = 1}, {name = "construction-robot", amount = 10}},
    {{name = "logistic-robot", amount = 2}, {name = "logistic-chest-passive-provider", amount = 1}, {name = "logistic-chest-storage", amount = 1}},
    {{name = "cluster-grenade", amount = 1}, {name = "piercing-shotgun-shell", amount = 3}},
    {{name = "personal-roboport-equipment", amount = 1}, {name = "power-armor", amount = 1}},
    {{name = "destroyer-capsule", amount = 1}, {name = "uranium-rounds-magazine", amount = 10}},
    {{name = "artillery-turret", amount = 1}, {name = "artillery-shell", amount = 1}},
    {{name = "rocket-control-unit", amount = 1}, {name = "low-density-structure", amount = 1}, {name = "rocket-fuel", amount = 1}},
    {{name = "satellite", amount = 1}}
}

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

SciencePackGalore.seed = settings.startup[SciencePackGalore.prefix("seed")].value

SciencePackGalore.enable_random_craft_time = settings.startup[SciencePackGalore.prefix("randomize-craft-time")].value
SciencePackGalore.enable_random_pack_recipes = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes")].value

SciencePackGalore.first_pack_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-first-pack-cost")].value
SciencePackGalore.last_pack_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-last-pack-cost")].value

SciencePackGalore.energy_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-energy-cost")].value -- per J
SciencePackGalore.time_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-time-cost")].value -- per second
SciencePackGalore.raw_resource_cost = settings.startup[SciencePackGalore.prefix("randomize-pack-recipes-raw-resource-cost")].value -- per raw resource
SciencePackGalore.entity_cost = SciencePackGalore.raw_resource_cost -- per entity

math.randomseed(SciencePackGalore.seed)