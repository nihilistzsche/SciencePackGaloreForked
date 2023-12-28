-- For each pack, get the last required tech for its components

pack_prereqs = {}
pack_requirement_tech = {}

for i=1, total_packs do
    science_pack_ingredients[i] = table.deepcopy(data.raw.recipe[SciencePackGalore.prefix("science-pack-" .. i)].ingredients)

    pack_requirement_tech[i] = tech_order[1]
    pack_prereqs[i] = {}
    for _, item in pairs(science_pack_ingredients[i]) do
        if not item_techs[item.name] and not base_items[item.name] then
            log("The item " .. item.name .. " in science pack " .. i .. " might be uncraftable")
        end
        if item_techs[item.name] and not base_items[item.name] then
            local in_pack_prereqs = false
            for _, key in pairs(pack_prereqs[i]) do
                if key == item_techs[item.name] then
                    in_pack_prereqs = true
                end
            end
            if in_pack_prereqs == false then
                if enable_logging then
                    log("Science pack " .. i .. " has a prerequisite " .. item_techs[item.name])
                end
                table.insert(pack_prereqs[i], item_techs[item.name])
            end
            if tech_order_reverse[item_techs[item.name]] > tech_order_reverse[pack_requirement_tech[i]] then
                pack_requirement_tech[i] = item_techs[item.name]
            end
        end
    end
    if SciencePackGalore.tableSize(pack_prereqs[i]) == 0 then
        table.insert(pack_prereqs[i], pack_requirement_tech[i])
    end
end