//KrakenTech Turbo Rotor/bladeseller Lib
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

//Get rotor angle
function rotorang
{
    parameter vess. //Main vessel.
    local x is vdot(vess:facing:forevector, ship:facing:upvector).
    local y is vdot(-vess:facing:starvector, ship:facing:upvector).
    local res is arctan2(y, x).
    if res < 0 {return 360 + res.}
    else {return res.}
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
    local lock plock  to ship:partstagged("plock").
    local lock blade1 to ship:partstagged("rblade1").
    local lock blade2 to ship:partstagged("rblade2").
    local lock blade3 to ship:partstagged("rblade3").
    local lock blade4 to ship:partstagged("rblade4").
    local lock claws  to ship:partstagged("rclaw").
    local recv is 0.
    local coll is 0.
    local rpitch is 0.
    local rroll is 0.
    local cycl is 12.
    local cyc1 is 0.
    local cyc2 is 0.
    local cyc3 is 0.
    local cyc4 is 0.
    local qd1 is 0.
    local qd2 is 0.
    local qd3 is 0.
    local qd4 is 0.
    local lock rang to rotorang(remote).
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
        set rpitch to (cycl * recv:content["pitch"]).
        set rroll to (cycl * recv:content["roll"]).
        set qd1 to coll - rpitch - rroll.
        set qd2 to coll + rpitch - rroll.
        set qd3 to coll + rpitch + rroll.
        set qd4 to coll - rpitch + rroll.
        if (ship:messages:empty) and (not remote:isdead) {remote:connection:sendmessage(send).}
        return true.
    }
    wait 0.
    
    until done
    {
        if (plock:length > 1) {return 0.}
        if (rang >= 350) or (rang < 80)
        {
            set cyc1 to qd1.
            set cyc2 to qd2.
            set cyc3 to qd3.
            set cyc4 to qd4.
        }
        else if (rang >= 80) and (rang < 170)
        {
            set cyc1 to qd2.
            set cyc2 to qd3.
            set cyc3 to qd4.
            set cyc4 to qd1.
        }
        else if (rang >= 170) and (rang < 260)
        {
            set cyc1 to qd3.
            set cyc2 to qd4.
            set cyc3 to qd1.
            set cyc4 to qd2.
        }
        else
        {
            set cyc1 to qd4.
            set cyc2 to qd1.
            set cyc3 to qd2.
            set cyc4 to qd3.
        }
        blade1[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc1).
        blade1[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc1).
        blade2[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc2).
        blade2[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc2).
        blade3[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc3).
        blade3[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc3).
        blade4[0]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc4).
        blade4[1]:getmodule("modulecontrolsurface"):setfield("authority limiter", cyc4).
        if(ship:angularvel:mag < 5) {set rlock to true.}
        else {set rlock to false.}
        wait 0.
    }
    return 0.
}

//Run
print ("running...").
local result is main().
clearscreen.
if (result = 0) reboot.
else print "Program exited with code " + result.