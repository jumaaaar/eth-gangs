---  primary and secondary colors id https://wiki.rage.mp/index.php?title=Vehicle_Colors
GangData = {
    none = { 
        label = 'No Gang', 
        template_url = "",
        logo_url = "",
        grades = { 
            ['0'] = { name = 'Unaffiliated' } 
        },
        ['GangTasks'] = vec3(0,0,0),
        ['SprayPaint'] = GetHashKey('sprays_gang1'),
        ["blipColor"] = 0,
        ["StashLocation"] =  vec3(0,0,0),
        ["BossActionLocation"] = vec3(0,0,0),
        ["VehicleActions"] =  {
            ["coords"] = vector4(0,0,0,0),
            ["colors"] = { 141, 0 },
            ["vehicles"] = {},
        }
     },
    elite = {
        label = 'Elite Syndicate',
        grades = {
            ['0'] = { name = 'Captains' },
            ['1'] = { name = 'Bishop' },
            ['2'] = { name = 'Counsel' },
            ['3'] = { name = 'King', isboss = true },
        },
        ['GangTasks'] = vec3(-1509.22,106.62,60.97),
        ['SprayPaint'] = GetHashKey('sprays_gang1'),
        ["blipColor"] = 85,
        ["StashLocation"] = vec3(-1526.2405, 135.0314, 55.5832),
        ["BossActionLocation"] = vec3(-1518.7866, 136.8715, 55.5832),
        ["VehicleActions"] = {
            ["coords"] = vector4(-1541.7675, 118.9625, 56.7801, 198.5085),
            ["colors"] = { 0, 0 },
            ["vehicles"] = {
                ["sunrise1"] = "Sunrise Sport",
                
            },

        }

    },
    trk = {
        label = 'TRIKRU',
        template_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK_GANG_TEMPLATE.png",
        logo_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK.png",
        grades = {
            ['0'] = { name = 'Prospect' },
            ['1'] = { name = 'TRK' },
            ['2'] = { name = 'OG' },
            ['3'] = { name = 'PATRON', isboss = true },
        },
        ['GangTasks'] = vec3(-1557.7, -374.04, 48.05),
        ['SprayPaint'] = GetHashKey('sprays_gang2'),
        ["blipColor"] = 36,
        ["StashLocation"] = vec3(-1556.69, -376.37, 48.05),
        ["BossActionLocation"] = vec3(-1561.54, -381.05, 48.05),
        ["VehicleActions"] = {
            ["coords"] =  vec4(-1563.82, -394.46, 41.71, 228.84),
            ["colors"] =  { 107, 0 },
            ["vehicles"] = {
                ["jugular"] = "Jugular",
                
            },

        }
    },

    santo = {
        label = 'S A N T O',
        template_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK_GANG_TEMPLATE.png",
        logo_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK.png",
        grades = {
            ['0'] = { name = 'ASSOCIADO' },
            ['1'] = { name = 'CARNAL' },
            ['2'] = { name = 'CHAPO' },
            ['3'] = { name = 'OG' },
            ['4'] = { name = 'SENIORES', isboss = true },
        },
        ['GangTasks'] = vec3(-17.82, -1443.54, 30.66),
        ['SprayPaint'] = GetHashKey('sprays_gang3'),
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

    mafia867 = {
        label = '867 Mafia',
        template_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK_GANG_TEMPLATE.png",
        logo_url = "https://r2.fivemanage.com/WcNmcqGHf2fa5LZLnVlft/images/TRK.png",
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Soldato ' },
            ['2'] = { name = 'Shot Caller ' },
            ['3'] = { name = 'Capo Regime ' },
            ['4'] = { name = 'QUEEN ' },
            ['6'] = { name = 'Kingpin ' },
            ['6'] = { name = 'Godfather', isboss = true },
        },
        ['GangTasks'] = vec3(1391.53, 1131.14, 109.76),
        ['SprayPaint'] = GetHashKey('sprays_gang4'),
        ["blipColor"] = 0,
        ["StashLocation"] = vec3(1400.02, 1139.61, 114.34),
        ["BossActionLocation"] = vec3(1394.2, 1160.19, 114.49),
        ["VehicleActions"] = {
            ["coords"] =  vec4(1409.56, 1118.8, 114.16, 90.8),
            ["colors"] =  { 131, 0 },
            ["vehicles"] = {
                ["jugular"] = "Jugular",
                
            },

        }
    },
    
}