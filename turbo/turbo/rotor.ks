//KrakenTech Turbo Controller - Rotor module
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.
set config:ipu to 500.

//Load config
function loadcfg
{
    local cfgname is "conf.json".
    if exists(cfgname) {return readjson(cfgname).}
    else {return false.}
}

//Get relative angle
function relangle
{
    parameter refp. //reference part/vessel.
    parameter refv. //reference vector.
    local x is vdot(refp:facing:forevector, refv).
    local y is vdot(-refp:facing:starvector, refv).
    local res is arctan2(y, x).
    if res < 0 {return 360 + res.}
    else {return res.}
}

//Get Cyclic
function cyclic
{
	parameter maxpitch.
	parameter inpt.
	parameter bld.
    set bld to mod(bld, 360).
    if bld < 0 {set bld to 360 + bld.}
    local rel is abs(inpt - bld).
    if rel > 180 {set rel to abs(rel - 360).}
	return maxpitch - ((rel / 90) * maxpitch).
}

//Entry Point
function main
{
    clearscreen.
    set terminal:width  to 40.
    set terminal:height to 8.
    local conf is loadcfg(). //Lexicon ["shipname"]<String>, ["remote"]<String>
    if not (conf:typename = "Lexicon") {return -1.}
    set ship:name to conf["shipname"].
    local remote is vessel(conf["remote"]).
    local recv is 0.
    local coll is 0.
    local rinput is v(0, 0, 0).
    local offset is -25.
    local cycl is 20.
    local cyc1 is 0.
    local cyc2 is 0.
    local cyc3 is 0.
    local cyc4 is 0.
    local lock plock  to ship:partstagged("plock").
    local lock blade1 to ship:partstagged("rblade1").
    local lock blade2 to ship:partstagged("rblade2").
    local lock blade3 to ship:partstagged("rblade3").
    local lock blade4 to ship:partstagged("rblade4").
    local lock claws  to ship:partstagged("rclaw").
    local lock mpitch to cycl * rinput:mag.
    local lock rang to relangle(remote:partstagged("refpoint")[0], ship:facing:upvector).
    local lock ivec to relangle(remote:partstagged("refpoint")[0], rinput).
    local lock send to ship:angularvel:mag.
    
    local rlock is false.
    on rlock
    {
        if rlock
        {
            for clw in claws{if clw:getmodule("ModuleGrappleNode"):hasevent("lock pivot"){clw:getmodule("ModuleGrappleNode"):doevent("lock pivot").}}
            for plk in plock{if plk:getmodule("ModuleAnimateGeneric"):hasevent("open shield"){plk:getmodule("ModuleAnimateGeneric"):doevent("open shield").}}
        }
        else
        {
            for clw in claws{if clw:getmodule("ModuleGrappleNode"):hasevent("free pivot"){clw:getmodule("ModuleGrappleNode"):doevent("free pivot").}}
            for plk in plock{if plk:getmodule("ModuleAnimateGeneric"):hasevent("close shield"){plk:getmodule("ModuleAnimateGeneric"):doevent("close shield").}}
        }
        ship:partstagged("rcore")[0]:getmodule("ModuleCommand"):doevent("control from here").
        return true.
    }
    wait 0.
    
    local done is false.
    ag4 off.
    on ag4 {set done to true. return true.}
    wait 0.
    
    when not ship:messages:empty then
    {
        set recv to ship:messages:pop().
        set coll to recv:content["coll"].
        set rinput to recv:content["input"].
        if (ship:messages:empty) and (not remote:isdead) {remote:connection:sendmessage(send).}
        return true.
    }
    wait 0.
    
    until done
    {
        if (plock:length > 1) {return 0.}
        set cyc1 to cyclic(mpitch, ivec, rang + offset) + coll.
        set cyc2 to cyclic(mpitch, ivec, rang + 90  + offset) + coll.
        set cyc3 to cyclic(mpitch, ivec, rang + 180 + offset) + coll.
        set cyc4 to cyclic(mpitch, ivec, rang + 270 + offset) + coll.
        blade1[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc1).
        blade1[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc1).
        blade2[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc2).
        blade2[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc2).
        blade3[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc3).
        blade3[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc3).
        blade4[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc4).
        blade4[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc4).
        if(ship:angularvel:mag < 3) {set rlock to true.}
        else {set rlock to false.}
        wait 0.
    }
    return 0.
}

//Run
print ("Running...").
local result is main().
clearscreen.
if (result = 0) reboot.
else print "Program exited with code " + result.