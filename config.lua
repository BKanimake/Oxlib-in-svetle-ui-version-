Config = {}

-- Distance in meters to activate interaction loop (0.00ms idle resmon when further away)
Config.DrawDistance = 15.0
Config.InteractDistance = 2.5

-- Controls
Config.InteractKey = 38 -- E key

-- Theme Park Rides Configuration
Config.Rides = {
    ferris_wheel = {
        label = "Ferris Wheel",
        price = 10,
        prompt = "[E] Ride Ferris Wheel ($10)",
        entryCoords = vec3(-1672.3, -1124.5, 13.0),
        exitCoords = vec3(-1672.3, -1120.0, 13.0),
        model = "prop_ld_ferris_wheel",
        duration = 60, -- duration in seconds for full ride cycle
        seats = 16
    },
    roller_coaster = {
        label = "Roller Coaster",
        price = 15,
        prompt = "[E] Ride Roller Coaster ($15)",
        entryCoords = vec3(-1643.2, -1077.5, 13.1),
        exitCoords = vec3(-1648.0, -1075.0, 13.1),
        model = "p_roller_coaster_s",
        duration = 45,
        seats = 12
    }
}
