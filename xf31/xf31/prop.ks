//(XF-31b Canary) Propeller Module
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 50.
    set terminal:height to 18.
    sas off.
    rcs off.
    gear off.
    lights off.
    brakes off.
    local lock plock to ship:partstagged("mport").
    local lock prop to ship:partstagged("pblade").
    local remote is vessel(ship:name:replace(" Probe", "")):connection.
    local recv is 0.
    local proplvl is 0.
    local thrt is 0.
    local lock send to ship:angularvel:mag.
    
    local done is false.
    ag1 off.
    on ag1 {set done to true. return true.}
    wait 0.
    
    when not ship:messages:empty then
    {
        set recv to ship:messages:pop().
        set proplvl to round(recv:content["proplvl"]).
        set thrt to recv:content["thrt"].
        for prp in prop {prp:getmodule("modulecontrolsurface"):setfield("authority limiter", proplvl).}
        if (thrt > 0) {set ship:control:neutralize to false. set ship:control:roll to thrt.}
        else {set ship:control:neutralize to true. set ship:control:roll to 0.}
        return true.
    }
    wait 0.
    
    until done
    {
        if (plock:length > 0) {return 0.}
        print ("AVMAG:" + send):padright(40) at(0, 1).
        print ("THRT: " + thrt):padright(40) at(0, 2).
        print ("PROP: " + round(prop[0]:getmodule("modulecontrolsurface"):getfield("authority limiter"))):padright(40) at(0, 3).
        remote:sendmessage(send).
        wait 0.25.
    }
    set ship:control:neutralize to true.
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) reboot.
else print "Program exited with code " + result.