//(Krakentech Helicopter Software) StandBy module
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

@lazyglobal off.

//Dotz <3
function prntDot
{
    parameter wt.   //Wait interval between Dotz
    parameter nod.  //Number of Dotz
    parameter col.  //Terminal Column
    parameter line. //Terminal Line
    from {local i is 0.} until (i >= nod) step {set i to i + 1.} do {print "." at((col + i), line). wait wt.}
}

//Load config
function loadcfg
{
    parameter cfgname is "conf.json".
    if exists(cfgname) {return readjson(cfgname).}
    else {return false.}
}

//Entry Point
function main
{
    clearscreen.
    ship:messages:clear().
    set terminal:width to 50.
    set terminal:height to 18.
    local conf is loadcfg(). //Lexicon ["shipname"]<String>, ["spindir"]<Bool>, ["type"]<String>, ["blades"]<String>
    if not (conf:typename = "Lexicon") {return -1.} //Config file not found
    local propready is false.
    local rready is 0.
    local recv is 0.
    
    until propready
    {
        if not ship:messages:empty
        {
            until ship:messages:empty
            {
                set recv to ship:messages:pop().
                if(recv:content = "ready"){set rready to (rready + 1).}
            }
        }
        if (ship:name <> conf["shipname"]) and (not conf["type"]:contains("Main"))
        {
            set propready to true.
            vessel(conf["shipname"]):connection:sendmessage("ready").
        }
        else if conf["type"]:contains("Main") and (rready > 1) {set propready to true.}
        
        print ("StandBy   "):padright(50) at(0, 1).
        prntDot(1, 3, 7, 1).
    }
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) runpath("firmware.ksm").
else print "Program exited with code " + result.