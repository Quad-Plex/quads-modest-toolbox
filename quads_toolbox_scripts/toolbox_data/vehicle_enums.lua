local eVehicleModType = {
       VMT_SPOILER = 0,
       VMT_BUMPER_F = 1,
       VMT_BUMPER_R = 2,
       VMT_SKIRT = 3,
       VMT_EXHAUST = 4,
       VMT_CHASSIS = 5,
       VMT_GRILL = 6,
       VMT_BONNET = 7,
       VMT_WING_L = 8,
       VMT_WING_R = 9,
       VMT_ROOF = 10,
       VMT_ENGINE = 11,
       VMT_BRAKES = 12,
       VMT_GEARBOX = 13,
       VMT_HORN = 14,
       VMT_SUSPENSION = 15,
       VMT_ARMOUR = 16,
       VMT_NITROUS = 17,
       VMT_TURBO = 18,
       VMT_SUBWOOFER = 19,
       VMT_TYRE_SMOKE = 20,
       VMT_HYDRAULICS = 21,
       VMT_XENON_LIGHTS = 22,
       VMT_WHEELS = 23,
       VMT_WHEELS_REAR_OR_HYDRAULICS = 24,
       VMT_PLTHOLDER = 25,
       VMT_PLTVANITY = 26,
       VMT_INTERIOR1 = 27,
       VMT_INTERIOR2 = 28,
       VMT_INTERIOR3 = 29,
       VMT_INTERIOR4 = 30,
       VMT_INTERIOR5 = 31,
       VMT_SEATS = 32,
       VMT_STEERING = 33,
       VMT_KNOB = 34,
       VMT_PLAQUE = 35,
       VMT_ICE = 36,
       VMT_TRUNK = 37,
       VMT_HYDRO = 38,
       VMT_ENGINEBAY1 = 39,
       VMT_ENGINEBAY2 = 40,
       VMT_ENGINEBAY3 = 41,
       VMT_CHASSIS2 = 42,
       VMT_CHASSIS3 = 43,
       VMT_CHASSIS4 = 44,
       VMT_CHASSIS5 = 45,
       VMT_DOOR_L = 46,
       VMT_DOOR_R = 47,
       VMT_LIVERY_MOD = 48
    }

local eVehicleWheelType = {
   VWT_SPORT = 0,
   VWT_MUSCLE = 1,
   VWT_LOWRIDER = 2,
   VWT_SUV = 3,
   VWT_OFFROAD = 4,
   VWT_TUNER = 5,
   VWT_BIKE = 6,
   VWT_HIEND = 7,
   VWT_SUPERMOD1 = 8, --Benny's Original
   VWT_SUPERMOD2 = 9, --Benny's Bespoke
   VWT_SUPERMOD3 = 10, --Open Wheel
   VWT_SUPERMOD4 = 11, --Street
   VWT_SUPERMOD5 = 12 --Track
}

local eVehicleColor = {
	VehicleColorMetallicBlack = 0,
	VehicleColorMetallicGraphiteBlack = 1,
	VehicleColorMetallicBlackSteel = 2,
	VehicleColorMetallicDarkSilver = 3,
	VehicleColorMetallicSilver = 4,
	VehicleColorMetallicBlueSilver = 5,
	VehicleColorMetallicSteelGray = 6,
	VehicleColorMetallicShadowSilver = 7,
	VehicleColorMetallicStoneSilver = 8,
	VehicleColorMetallicMidnightSilver = 9,
	VehicleColorMetallicGunMetal = 10,
	VehicleColorMetallicAnthraciteGray = 11,
	VehicleColorMatteBlack = 12,
	VehicleColorMatteGray = 13,
	VehicleColorMatteLightGray = 14,
	VehicleColorUtilBlack = 15,
	VehicleColorUtilBlackPoly = 16,
	VehicleColorUtilDarksilver = 17,
	VehicleColorUtilSilver = 18,
	VehicleColorUtilGunMetal = 19,
	VehicleColorUtilShadowSilver = 20,
	VehicleColorWornBlack = 21,
	VehicleColorWornGraphite = 22,
	VehicleColorWornSilverGray = 23,
	VehicleColorWornSilver = 24,
	VehicleColorWornBlueSilver = 25,
	VehicleColorWornShadowSilver = 26,
	VehicleColorMetallicRed = 27,
	VehicleColorMetallicTorinoRed = 28,
	VehicleColorMetallicFormulaRed = 29,
	VehicleColorMetallicBlazeRed = 30,
	VehicleColorMetallicGracefulRed = 31,
	VehicleColorMetallicGarnetRed = 32,
	VehicleColorMetallicDesertRed = 33,
	VehicleColorMetallicCabernetRed = 34,
	VehicleColorMetallicCandyRed = 35,
	VehicleColorMetallicSunriseOrange = 36,
	VehicleColorMetallicClassicGold = 37,
	VehicleColorMetallicOrange = 38,
	VehicleColorMatteRed = 39,
	VehicleColorMatteDarkRed = 40,
	VehicleColorMatteOrange = 41,
	VehicleColorMatteYellow = 42,
	VehicleColorUtilRed = 43,
	VehicleColorUtilBrightRed = 44,
	VehicleColorUtilGarnetRed = 45,
	VehicleColorWornRed = 46,
	VehicleColorWornGoldenRed = 47,
	VehicleColorWornDarkRed = 48,
	VehicleColorMetallicDarkGreen = 49,
	VehicleColorMetallicRacingGreen = 50,
	VehicleColorMetallicSeaGreen = 51,
	VehicleColorMetallicOliveGreen = 52,
	VehicleColorMetallicGreen = 53,
	VehicleColorMetallicGasolineBlueGreen = 54,
	VehicleColorMatteLimeGreen = 55,
	VehicleColorUtilDarkGreen = 56,
	VehicleColorUtilGreen = 57,
	VehicleColorWornDarkGreen = 58,
	VehicleColorWornGreen = 59,
	VehicleColorWornSeaWash = 60,
	VehicleColorMetallicMidnightBlue = 61,
	VehicleColorMetallicDarkBlue = 62,
	VehicleColorMetallicSaxonyBlue = 63,
	VehicleColorMetallicBlue = 64,
	VehicleColorMetallicMarinerBlue = 65,
	VehicleColorMetallicHarborBlue = 66,
	VehicleColorMetallicDiamondBlue = 67,
	VehicleColorMetallicSurfBlue = 68,
	VehicleColorMetallicNauticalBlue = 69,
	VehicleColorMetallicBrightBlue = 70,
	VehicleColorMetallicPurpleBlue = 71,
	VehicleColorMetallicSpinnakerBlue = 72,
	VehicleColorMetallicUltraBlue = 73,
	VehicleColorUtilDarkBlue = 75,
	VehicleColorUtilMidnightBlue = 76,
	VehicleColorUtilBlue = 77,
	VehicleColorUtilSeaFoamBlue = 78,
	VehicleColorUtilLightningBlue = 79,
	VehicleColorUtilMauiBluePoly = 80,
	VehicleColorUtilBrightBlue = 81,
	VehicleColorMatteDarkBlue = 82,
	VehicleColorMatteBlue = 83,
	VehicleColorMatteMidnightBlue = 84,
	VehicleColorWornDarkBlue = 85,
	VehicleColorWornBlue = 86,
	VehicleColorWornLightBlue = 87,
	VehicleColorMetallicTaxiYellow = 88,
	VehicleColorMetallicRaceYellow = 89,
	VehicleColorMetallicBronze = 90,
	VehicleColorMetallicYellowBird = 91,
	VehicleColorMetallicLime = 92,
	VehicleColorMetallicChampagne = 93,
	VehicleColorMetallicPuebloBeige = 94,
	VehicleColorMetallicDarkIvory = 95,
	VehicleColorMetallicChocoBrown = 96,
	VehicleColorMetallicGoldenBrown = 97,
	VehicleColorMetallicLightBrown = 98,
	VehicleColorMetallicStrawBeige = 99,
	VehicleColorMetallicMossBrown = 100,
	VehicleColorMetallicBistonBrown = 101,
	VehicleColorMetallicBeechwood = 102,
	VehicleColorMetallicDarkBeechwood = 103,
	VehicleColorMetallicChocoOrange = 104,
	VehicleColorMetallicBeachSand = 105,
	VehicleColorMetallicSunBleechedSand = 106,
	VehicleColorMetallicCream = 107,
	VehicleColorUtilBrown = 108,
	VehicleColorUtilMediumBrown = 109,
	VehicleColorUtilLightBrown = 110,
	VehicleColorMetallicWhite = 111,
	VehicleColorMetallicFrostWhite = 112,
	VehicleColorWornHoneyBeige = 113,
	VehicleColorWornBrown = 114,
	VehicleColorWornDarkBrown = 115,
	VehicleColorWornStrawBeige = 116,
	VehicleColorBrushedSteel = 117,
	VehicleColorBrushedBlackSteel = 118,
	VehicleColorBrushedAluminium = 119,
	VehicleColorChrome = 120,
	VehicleColorWornOffWhite = 121,
	VehicleColorUtilOffWhite = 122,
	VehicleColorWornOrange = 123,
	VehicleColorWornLightOrange = 124,
	VehicleColorMetallicSecuricorGreen = 125,
	VehicleColorWornTaxiYellow = 126,
	VehicleColorPoliceCarBlue = 127,
	VehicleColorMatteGreen = 128,
	VehicleColorMatteBrown = 129,
	VehicleColorMatteWhite = 131,
	VehicleColorWornWhite = 132,
	VehicleColorWornOliveArmyGreen = 133,
	VehicleColorPureWhite = 134,
	VehicleColorHotPink = 135,
	VehicleColorSalmonpink = 136,
	VehicleColorMetallicVermillionPink = 137,
	VehicleColorOrange = 138,
	VehicleColorGreen = 139,
	VehicleColorBlue = 140,
	VehicleColorMettalicBlackBlue = 141,
	VehicleColorMetallicBlackPurple = 142,
	VehicleColorMetallicBlackRed = 143,
	VehicleColorHunterGreen = 144,
	VehicleColorMetallicPurple = 145,
	VehicleColorMetaillicVDarkBlue = 146,
	VehicleColorModshopBlack1 = 147,
	VehicleColorMattePurple = 148,
	VehicleColorMatteDarkPurple = 149,
	VehicleColorMetallicLavaRed = 150,
	VehicleColorMatteForestGreen = 151,
	VehicleColorMatteOliveDrab = 152,
	VehicleColorMatteDesertBrown = 153,
	VehicleColorMatteDesertTan = 154,
	VehicleColorMatteFoliageGreen = 155,
	VehicleColorDefaultAlloyColor = 156,
	VehicleColorEpsilonBlue = 157,
	VehicleColorPureGold = 158,
	VehicleColorBrushedGold = 159
}