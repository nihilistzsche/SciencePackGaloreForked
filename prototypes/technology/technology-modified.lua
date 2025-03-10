-- Place science packs on all technologies depending on their requirements

for i=1, total_packs do
    local tech_placed = {}
    tech_placed[pack_requirement_tech[i]] = true
    -- Also continue other packs
    for j=1, total_packs do
        if tech_order_reverse[pack_requirement_tech[j]] > tech_order_reverse[pack_requirement_tech[i]] then
            tech_placed[pack_requirement_tech[j]] = true
        end
    end
    for _, key in pairs(tech_order) do
        if data.raw.technology[key].prerequisites then
            local requires_pack = false
            for _, prereq in pairs(data.raw.technology[key].prerequisites) do
                if tech_placed[prereq] then
                    requires_pack = true
                end
            end
            if requires_pack == true then
                tech_placed[key] = true
                table.insert(data.raw.technology[key].unit.ingredients, {SciencePackGalore.prefix("science-pack-" .. i), 1})
            end
        end
    end
end

-- Move all children of the main prereq tech of a science pack to requiring said science pack

local tech_packs = {}
for i=1, total_packs do
    if not tech_packs[pack_requirement_tech[i]] then
        tech_packs[pack_requirement_tech[i]] = {}
    end
    table.insert(tech_packs[pack_requirement_tech[i]], SciencePackGalore.prefix("science-pack-" .. i .. "-tech"))
end

for key, val in pairs(data.raw.technology) do
    if val.prerequisites then
        local new_prereqs = {}
        for _, prereq in pairs(val.prerequisites) do
            if not tech_packs[prereq] then
                table.insert(new_prereqs, prereq)
            else
                for _, tech_pack in pairs(tech_packs[prereq]) do
                    table.insert(new_prereqs, tech_pack)
                end
            end
        end
        data.raw.technology[key].prerequisites = new_prereqs
    end
end

-- Fix science pack technologies

for i=1, total_packs do
    local key = SciencePackGalore.prefix("science-pack-" .. i .. "-tech")
    data.raw.technology[key].prerequisites = table.deepcopy(pack_prereqs[i])
    local keys_to_remove = {}
    for j, pr in pairs(data.raw.technology[key].prerequisites) do
        if pr == key then
            table.insert(keys_to_remove, j)
        end
    end
    for _, keyIndex in pairs(keys_to_remove) do
        table.remove(data.raw.technology[key].prerequisites, keyIndex)
    end
    data.raw.technology[key].unit = table.deepcopy(data.raw.technology[pack_requirement_tech[i]].unit)
    if data.raw.technology[key].unit.count_formula then
        table.remove(data.raw.technology[key].unit, "count_formula")
        data.raw.technology[key].unit.count = 1000
    end
    data.raw.technology[key].unit.count = data.raw.technology[key].unit.count * 2
end