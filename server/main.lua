local activeRides = {}

RegisterNetEvent('delperro_pier:sv_startRide', function(rideId)
    local src = source
    if not Config.Rides[rideId] then return end

    if not activeRides[rideId] then
        activeRides[rideId] = {
            inProgress = true,
            riders = {}
        }
    end

    table.insert(activeRides[rideId].riders, src)
    TriggerClientEvent('delperro_pier:cl_startRide', src, rideId)
    TriggerClientEvent('delperro_pier:cl_syncRideState', -1, rideId, true)
end)

RegisterNetEvent('delperro_pier:sv_exitRide', function(rideId)
    local src = source
    TriggerClientEvent('delperro_pier:cl_exitRide', src, rideId)
end)
