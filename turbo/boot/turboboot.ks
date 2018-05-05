//(Krakentech Turbo Helicopter Software) Bootloader
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

@lazyglobal off.

global mcpu is "main_cpu".
global rcpu is "rotor_cpu".
global spath is "0:/turbo/".

function writeconf
{
    parameter cpu.
    parameter cname.
    parameter rname.
    local conf is lexicon("shipname", cname, "remote", rname).
    writejson(conf, (cpu + ":/conf.json")).
}

//Entry Point
function main
{    
    print "initializing...".
    local cpulist is 0.
    list processors in cpulist.
    for cpus in cpulist
    {
        if (cpus:volume:name = mcpu)
        {
            writeconf(mcpu, ship:name, ship:name + " Rotor").
            compile spath + "main.ks"  to mcpu + ":/firmware.ksm".
            compile spath + "stdby.ks" to mcpu + ":/stdby.ksm".
        }
        else if (cpus:volume:name = rcpu)
        {
            writeconf(rcpu, ship:name + " Rotor", ship:name).
            compile spath + "rotor.ks" to rcpu + ":/firmware.ksm".
            compile spath + "stdby.ks" to rcpu + ":/stdby.ksm".
        }
        else
        {
            print "Helicopter CPU not found".
            return -1.
        }
    }
    print "Initialization Ok.".
    return 0.
}

//Run
local result is main().
if (result < 0) print "Program exited with code " + result.
runpath("stdby.ksm").