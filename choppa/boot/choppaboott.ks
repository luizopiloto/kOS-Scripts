//(Krakentech Helicopter Software) Bootloader
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

@lazyglobal off.

//Entry Point
function main
{
    clearscreen.
    print "initializing...".
    local cpuname is "tail_cpu".
    local cpulist is 0.
    local rcpu is false.
    local tcpu is false.
    local mcpu is false.
    list processors in cpulist.
    for cpus in cpulist
    {
        if (cpus:volume:name = cpuname)
        {
            //Lexicon ["shipname"]<String>, ["spindir"]<Bool>, ["type"]<String>, ["blades"]<String>
            local conf is lexicon("shipname", ship:name, "spindir", false, "type", "Tail", "blades", "tblade").
            writejson(conf, (cpuname + ":/conf.json")).
            compile "0:/choppa/prop.ks" to (cpuname + ":/firmware.ksm").
            compile "0:/choppa/stdby.ks" to (cpuname + ":/stdby.ksm").
            set tcpu to true.
        }
    }
    if tcpu {print "Initialization Ok.". wait 1. return 0.}
    else    {print "Initialization error.". return -1.}
}

//Run
local result is main().
clearscreen.
if (result = 0) runpath("stdby.ksm").
print "Program exited with code " + result.