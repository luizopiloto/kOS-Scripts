//(XF-31b Canary) Plane Module
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Globals
global cfgname is "conf.json".
global conf is lexicon().
conf:add("kp", -0.37).
conf:add("ki", -0.61).
conf:add("kd", -0.16).
conf:add("prp", 0).
conf:add("rpm", 420).

//Get RPM
function prop_rpm
{
    parameter propmag is 0.
    return round(((propmag - ship:angularvel:mag) * (1 / (2 * constant:pi))) * 60).
}

//Load config
function loadcfg
{
    if exists(cfgname) {set conf to readjson(cfgname).}
    else {writejson(conf, cfgname).}
}

//Write config
function writecfg
{
    parameter ckp.
    parameter cki.
    parameter ckd.
    parameter cpr.
    parameter crpm.
    set conf["kp"] to ckp.
    set conf["ki"] to cki.
    set conf["kd"] to ckd.
    set conf["prp"] to cpr.
    set conf["rpm"] to crpm.
    writejson(conf, cfgname).
}

//Print Help.
function printhelp
{
    parameter mmode is false.
    if mmode
    {
        print ("(AG1)-Reboot.   (AG2)-Autoprop.   (AG3)-Prop Tune."):padright(40) at(0, 14).
        print ("__________________________________________________"):padright(40) at(0, 15).
        print ("(Trans.UP/DN)-Adj. Gain |(Trans.FW/BK)-Adj. Deriv."):padright(40) at(0, 16).
        print ("(Trans. L/R )-Adj. Int. |"):padright(40) at(0, 17).
    }
    else
    {
        print ("(AG1)-Reboot.   (AG2)-Autoprop.   (AG3)-PID  Tune."):padright(40) at(0, 14).
        print ("__________________________________________________"):padright(40) at(0, 15).
        print ("(Trans.UP/DN)-Adj.MaxRPM|"):padright(40) at(0, 16).
        print ("(Trans. L/R )-Adj.Prop. |"):padright(40) at(0, 17).
    }
}

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 50.
    set terminal:height to 18.
    loadcfg().
    local lock plock to ship:partstagged("prport").
    local remote is vessel(ship:name + " Probe"):connection.
    local recv is 0.
    local prpm is 0.
    local plvl is conf["prp"].
    local ls is 0.
    local lst is 0.
    local lstt is 0.
    local send is lexicon().
    send:add("proplvl", 0).
    send:add("thrt", 0).
    
    //AutoProp PID controller
    local maxrpm is conf["rpm"].
    local propPID is pidloop(conf["kp"], conf["ki"], conf["kd"], -50, 150).
    
    local done is false.
    ag1 off.
    on ag1 {set done to true. return true.}
    wait 0.
    
    local autoprp is false.
    ag2 off.
    on ag2 {clearscreen. set autoprp to ag2. printhelp(ag3). return true.}
    wait 0.
    
    local tune is false.
    ag3 off.
    printhelp(ag3).
    on ag3 {clearscreen. set tune to ag3. printhelp(ag3). return true.}
    wait 0.
    
    until done
    {
        if (plock:length > 0) {writecfg(propPID:kp, propPID:ki, propPID:kd, plvl, maxrpm). return 0.}
        if not ship:messages:empty
        {
            set recv to ship:messages:peek.
            set prpm to prop_rpm(recv:content).
            ship:messages:clear().
        }
        if autoprp
        {
            set lst to plvl.
            set propPID:setpoint to maxrpm.
            set plvl to round(propPID:update(time:seconds, prpm)).
            if (plvl < lst)
            {
                set ls to (time:seconds - lstt).
                set lstt to time:seconds.
            }
        }
        if tune
        {
            //Pid Tune Input
            if (ship:control:pilottop > 0)
            {
              if (propPID:kp > -0.01) {set propPID:kp to 0.}
              else {set propPID:kp to propPID:kp + 0.01.}
            } 
            else if (ship:control:pilottop < 0)
            {
              if (propPID:kp < -4.99) {set propPID:kp to -5.}
              else {set propPID:kp to propPID:kp - 0.01.}
            }
            
            if (ship:control:pilotstarboard > 0)
            {
              if (propPID:ki > -0.01) {set propPID:ki to 0.}
              else {set propPID:ki to propPID:ki + 0.01.}
            } 
            else if (ship:control:pilotstarboard < 0)
            {
              if (propPID:ki < -4.99) {set propPID:ki to -5.}
              else {set propPID:ki to propPID:ki - 0.01.}
            }
            
            if (ship:control:pilotfore > 0)
            {
              if (propPID:kd > -0.01) {set propPID:kd to 0.}
              else {set propPID:kd to propPID:kd + 0.01.}
            } 
            else if (ship:control:pilotfore < 0)
            {
              if (propPID:kd < -4.99) {set propPID:kd to -5.}
              else {set propPID:kd to propPID:kd - 0.01.}
            }
            print("PID Tune"):padright(40) at(0, 6).
            print(" P: " + propPID:kp):padright(40) at(0, 7).
            print(" I: " + propPID:ki):padright(40) at(0, 8).
            print(" D: " + propPID:kd):padright(40) at(0, 9).
            print(" V: " + ls):padright(40) at(0, 10).
        }
        else
        {
            //Prop Tune Input
            if (ship:control:pilottop > 0)
            {
              if (maxrpm > 439) {set maxrpm to 440.}
              else {set maxrpm to round(maxrpm + 10).}
            } 
            else if (ship:control:pilottop < 0)
            {
              if (maxrpm < 291) {set maxrpm to 290.}
              else {set maxrpm to round(maxrpm - 10).}
            }
            
            if ((ship:control:pilotstarboard > 0) and (not autoprp))
            {
              if (plvl > 149) {set plvl to 150.}
              else {set plvl to round(plvl + 1).}
            } 
            else if ((ship:control:pilotstarboard < 0) and (not autoprp))
            {
              if (plvl < -49) {set plvl to -50.}
              else {set plvl to round(plvl - 1).}
            }
            print("Prop Tune"):padright(40) at(0, 6).
            print(" RPM: " + maxrpm):padright(40) at(0, 7).
            if (ship:control:pilotmainthrottle > 0)
            {
                if not autoprp {print(" LVL: " + plvl):padright(40) at(0, 8).}
                else {print(" LVL: Auto"):padright(40) at(0, 8).}
            }
            else {print(" LVL: FEATHERED"):padright(40) at(0, 8).}
        }
        set send["thrt"] to ship:control:pilotmainthrottle.
        if (ship:control:pilotmainthrottle > 0)
        {
            set send["proplvl"] to plvl.
            print("PROP:" + plvl):padright(40) at(0, 2).
        }
        else
        {
            set send["proplvl"] to 150.
            print("PROP:FEATHERED"):padright(40) at(0, 2).
        }
        remote:sendmessage(send).
        print("RPM: " + prpm + "/" + maxrpm):padright(40) at(0, 1).
        print("THRT:" + round(send["thrt"] * 100)):padright(40) at(0, 3).
        print("AUTO:" + autoprp):padright(40) at(0, 4).
        wait 0.225.
    }
    writecfg(propPID:kp, propPID:ki, propPID:kd, plvl, maxrpm).
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) reboot.
else print "Program exited with code " + result.