require("functions")

data:extend({
    {
        type = "bool-setting",
        name = SciencePackGalore.prefix("randomize-craft-time"),
        setting_type = "startup",
        default_value = false,
        order = "b"
    },
    {
        type = "bool-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes"),
        setting_type = "startup",
        default_value = false,
        order = "b-a"
    },
    {
        type = "double-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes-energy-cost"),
        setting_type = "startup",
        default_value = 0.0000005,
        order = "b-b"
    },
    {
        type = "double-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes-time-cost"),
        setting_type = "startup",
        default_value = 0.05,
        order = "b-c"
    },
    {
        type = "double-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes-raw-resource-cost"),
        setting_type = "startup",
        default_value = 1,
        order = "b-d"
    },
    {
        type = "double-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes-first-pack-cost"),
        setting_type = "startup",
        default_value = 0.5,
        order = "b-e"
    },
    {
        type = "double-setting",
        name = SciencePackGalore.prefix("randomize-pack-recipes-last-pack-cost"),
        setting_type = "startup",
        default_value = 250,
        order = "b-f"
    },
})