//KrakenTech Rotor/Propeller Lib (Prop Module)
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Load config
function loadcfg
{
    parameter cfgname is "conf.json".
    if exists(cfgname) {return readjson(cfgname).}
    else {return false.}
}

function cwccw {parameter dir. if dir {return 1.} else {return -1.}}

//Triggers
local done is false.
ag1 off.
on ag1 {set done to true. return true.}
wait 0.

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 50.
    set terminal:height to 18.
    sas off.
    rcs off.
    gear off.
    lights on.
    brakes off.
    
    local conf is loadcfg(). //Lexicon ["shipname"]<String>, ["spindir"]<Bool>, ["type"]<String>, ["blades"]<String>
    if not (conf:typename = "Lexicon") {return -1.} //Config file not found
    set ship:name to (conf["shipname"] + " " + conf["type"]).
    local lock prop to ship:partstagged(conf["blades"]).
    local recv is 0.
    local proplvl is 0.
    local thrt is 0.
    local remote is vessel(conf["shipname"]).
    local spindir is conf["spindir"].
    local lock avmag to ship:angularvel:mag.
    
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
        if (thrt > 0) {set ship:control:neutralize to false. set ship:control:roll to (thrt * cwccw(spindir)).}
        else {set ship:control:neutralize to true. set ship:control:roll to 0.}
        return true.
    }
    wait 0.
    
    until done
    {
        if (remote:isdead or (ship:name = remote:name)){return 0.}
        print ("AVMAG:" + avmag):padright(40) at(0, 1).
        print ("THRT: " + thrt):padright(40) at(0, 2).
        print ("PROP: " + round(prop[0]:getmodule("modulecontrolsurface"):getfield("authority limiter"))):padright(40) at(0, 3).
        remote:connection:sendmessage(avmag).
        wait 0.05.
    }
    set ship:control:neutralize to true.
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) {reboot.}
else print("Program exited with code " + result).