-- Import section
local parser = require("lib.utils.parser")

local states = require("server.entities.states")

local getMachine = require("server.usecases.get-machine")
local getNumberOfProblems = require("server.usecases.get-number-of-problems")

--

local function exec(address, name, location)
    local lsc = getMachine(address, name, location, require("server.entities.mocks.mock-lsc"))
    if not lsc then
        return {name = name, state = states.MISSING, location = location}
    end

    local sensorInformation = lsc:getSensorInformation()

    local problems = getNumberOfProblems(sensorInformation[9])

    local state = nil
    if lsc:isWorkAllowed() then
        if lsc:hasWork() then
            state = states.ON
        else
            state = states.IDLE
        end
    else
        state = states.OFF
    end

    if problems > 0 then
        state = states.BROKEN
    end

    local status = {
        name = name,
        state = state,
        storedEU = parser.getInteger(sensorInformation[2]),
        EUCapacity = parser.getInteger(sensorInformation[3]),
        problems = problems,
        passiveLoss = parser.getInteger(sensorInformation[4]),
        location = location
    }
    return status
end

return exec
