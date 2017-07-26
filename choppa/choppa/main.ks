//(Krakentech Helicopter Software) Main craft module
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

@lazyglobal off.

//Globals
global rotorlst is lexicon().

//Revolutions per Minute
function getrpm
{
    parameter ravmag.      //Propeller/Rotor Angular Velocity Mag.
    parameter savmag is 0. //Ship Angular Velocity Mag. **ship:angularvel:mag**
    return (((ravmag - savmag) * (1 / (2 * constant:pi))) * 60).
}

global done is false.
ag1 off.
on ag1 {set done to true. return true.}
wait 0.

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 50.
    set terminal:height to 18.
    //Setup Main Rotor and Tail Rotor.
    local rotor is vessel(ship:name + " Rotor"):connection.
    local tail is vessel(ship:name + " Tail"):connection.
    local rrpm is 0.
    local trpm is 0.
    local lock coll to (((ship:control:pilotmainthrottle * 2) - 1) * 30).
    local lock tyaw to (ship:control:pilotyaw * 70).
    local ytrim is 0.
    local thrt is 0.
    local recv is 0.
    local rsend is lexicon("proplvl", 0, "thrt", 0).
    local tsend is lexicon("proplvl", 0, "thrt", 0).
    
    when not ship:messages:empty then
    {
        set recv to ship:messages:pop().
        if(recv:sender:name:contains(" Rotor")) {set rrpm to getrpm(recv:content, ship:angularvel:mag).}
        if(recv:sender:name:contains(" Tail"))  {set trpm to getrpm(recv:content, ship:angularvel:mag).}
        return true.
    }
    wait 0.
    
    until done
    {
        local rotor is vessel(ship:name + " Rotor").
        local tail is vessel(ship:name + " Tail").
        
        set rsend["proplvl"] to round(coll).
        set rsend["thrt"] to thrt.
        rotor:connection:sendmessage(rsend).
        
        set tsend["proplvl"] to round(tyaw + ytrim).
        set tsend["thrt"] to thrt.
        tail:connection:sendmessage(tsend).
        
        //Rotor Throttle Input
        if (ship:control:pilottop > 0)
        {
          if (thrt > 0.9) {set thrt to 1.}
          else {set thrt to thrt + 0.1.}
        } 
        else if (ship:control:pilottop < 0)
        {
          if (thrt < 0.1) {set thrt to 0.}
          else {set thrt to thrt - 0.1.}
        }
        
        //Tail Trim Input
        if (ship:control:pilotstarboard > 0)
        {
          if (ytrim > 69) {set ytrim to 70.}
          else {set ytrim to ytrim + 1.}
        } 
        else if (ship:control:pilotstarboard < 0)
        {
          if (ytrim < -69) {set ytrim to -70.}
          else {set ytrim to ytrim - 1.}
        }
        
        print("Rotor:  " + round(rrpm) + "RPM"):padright(40) at(0,1).
        print("Tail:   " + round(trpm) + "RPM"):padright(40) at(0,2).
        print("Thrt:   " + round(thrt * 100)):padright(40) at(0,3).
        print("Col:    " + round(coll)):padright(40) at(0,4).
        print("YawTrim:" + round(ytrim)):padright(40) at(0,5).
        wait 0.05.
    }
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) reboot.
print "Program exited with code " + result.