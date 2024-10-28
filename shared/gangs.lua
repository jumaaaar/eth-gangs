---  primary and secondary colors id https://wiki.rage.mp/index.php?title=Vehicle_Colors
GangData = {
    none = { 
        label = 'No Gang', 
        grades = { 
            ['0'] = { name = 'Unaffiliated' } 
        },
        ["blipColor"] = 0,
        ["StashLocation"] =  vec3(0,0,0),
        ["BossActionLocation"] = vec3(0,0,0),
        ["VehicleActions"] =  {
            ["coords"] = vector4(0,0,0,0),
            ["colors"] = { 141, 0 },
            ["vehicles"] = {},
        }
     },
    santo = {
        label = 'S A N T O',
        grades = {
            ['0'] = { name = 'ASSOCIADO' },
            ['1'] = { name = 'CARNAL' },
            ['2'] = { name = 'CHAPO' },
            ['3'] = { name = 'OG' },
            ['4'] = { name = 'SENIORES', isboss = true },
        },
        ["blipColor"] = 38,
        ["StashLocation"] = vec3(-16.97, -1440.79, 31.1),
        ["BossActionLocation"] = vec3(-10.75, -1440.64, 31.1),
        ["VehicleActions"] = {
            ["coords"] =  vec4(-24.31, -1436.46, 30.65, 183.32),
            ["colors"] =  { 83, 0 },
            ["vehicles"] = {
                ["jugular"] = "Jugular",
                
            },

        }
    },
}