for key, val in pairs(data.raw.lab) do
    if val.inputs ~= nil then
        lab_inputs = {}
        for _, lab_input in pairs(val.inputs) do
            lab_inputs[lab_input] = true
        end
        for i=1, total_packs do
            if not lab_inputs[SciencePackGalore.prefix("science-pack-" .. i)] then
                table.insert(data.raw.lab[key].inputs, SciencePackGalore.prefix("science-pack-" .. i))
                -- log("Added " .. SciencePackGalore.prefix("science-pack-" .. i) .. " to the lab " .. key .. ".")
            end
        end
    end
end