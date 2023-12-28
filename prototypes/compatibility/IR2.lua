-- Industrial Revolution 2 overhauls the progression; so, there are some changes in the science pack recipes.

if mods["IndustrialRevolution"] then
    -- Tin instead of iron
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "iron-ore", "tin-ore")
    -- Bronze instead of steel
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "steel-plate", "bronze-ingot")
    -- Shotguns instead of submachine guns
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "firearm-magazine", "shotgun-shell")
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "submachine-gun", "monowheel")
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "gun-turret", "scattergun-turret")
    -- Furnaces moved a level upwards
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "steel-furnace", "electric-furnace")
    -- Military 2 changed into Military 1
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "piercing-rounds-magazine", "firearm-magazine")
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "grenade", "iron-cartridge")
    -- Inserters instead of fast inserters
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "fast-inserter", "inserter")
    -- Grenade instead of poison capsule
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "poison-capsule", "grenade")
    -- Robotower instead of roboport
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "roboport", "robotower")
    -- Poison capsule instead of cluster grenade
    SciencePackGalore.recursiveReplaceName(science_pack_ingredients, "cluster-grenade", "poison-capsule")

    -- Names
    data.raw.tool[SciencePackGalore.prefix("science-pack-4")].localised_name = {"item-name." .. SciencePackGalore.prefix("science-pack-4-IR2")}
    data.raw.technology[SciencePackGalore.prefix("science-pack-4-tech")].localised_name = {"item-name." .. SciencePackGalore.prefix("science-pack-4-IR2")}
end