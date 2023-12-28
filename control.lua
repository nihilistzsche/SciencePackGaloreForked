remote.add_interface("SciencePackGaloreForked", {
    milestones_preset_addons = function()
        local ret = {
            ["SciencePackGaloreForked"] = {
                required_mods = { "SciencePackGaloreForked" },
                milestones = {
                    { type = "group", name = "Science" },
                },
            },
        }
        local tbl = ret["SciencePackGaloreForked"]
        for _, science in pairs(game.item_prototypes) do
            if science and science.type == "tool" and science.name:sub(1, 7) == "sem:spg" then
                log("Adding milestone for: " .. science.name)
                table.insert(tbl.milestones, { type = "item", name = science.name, quantity = 1 })
                table.insert(tbl.milestones, { type = "item", name = science.name, quantity = 1000, next = "x10" })
            end
        end
        return ret
    end,
})
