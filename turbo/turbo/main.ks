//(Krakentech Helicopter Software) Main craft module
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

@lazyglobal off.

//Revolutions per Minute
function getrpm
{
    parameter ravmag.      //Propeller/Rotor Angular Velocity Mag.
    parameter savmag is 0. //Ship Angular Velocity Mag. **ship:angularvel:mag**
    return (((ravmag - savmag) / (2 * constant:pi)) * 60).
}

//Load config
function loadcfg
{
    local cfgname is "conf.json".
    if exists(cfgname) {return readjson(cfgname).}
    else {return false.}
}

global done is false.
ag4 off.
on ag4 {set done to true. return true.}
wait 0.

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 40.
    set terminal:height to 8.
    //Setup Main Rotor
    local conf is loadcfg(). //Lexicon ["shipname"]<String>, ["remote"]<String>
    if not (conf:typename = "Lexicon") {return -1.}
    set ship:name to conf["shipname"].
    local remote is vessel(conf["remote"]).
    local lock plock to ship:partstagged("plock").
    local rrpm is 0.
    local coll to 0.
    local recv is 0.
    local send is lexicon("coll", 0, "pitch", 0, "roll", 0).

    when not ship:messages:empty then
    {
        set recv to ship:messages:pop().
        if(recv:sender:name:contains(ship:name)) {set rrpm to getrpm(recv:content, ship:angularvel:mag).}
        return true.
    }
    wait 0.

    until done
    {
        if (plock:length > 1) {return 0.}
        set send["coll"]  to coll.
        set send["pitch"] to ship:control:pilotpitch.
        set send["roll"]  to ship:control:pilotroll.
        if not remote:isdead {remote:connection:sendmessage(send).}

        //Collective Input
        if (ship:control:pilottop > 0)
        {
            if (coll > 24) {set coll to 25.}
            else {set coll to coll + 1.}
        } 
        else if (ship:control:pilottop < 0)
        {
            if (coll < -14) {set coll to -15.}
            else {set coll to coll - 1.}
        }

        print("Rotor: " + round(rrpm) + "RPM"):padright(40) at(0,1).
        print("Thrt:  " + round(ship:control:pilotmainthrottle * 100)):padright(40) at(0,2).
        print("Col:   " + round(coll)):padright(40) at(0,3).
        wait 0.025.
    }
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) reboot.
print "Program exited with code " + result.