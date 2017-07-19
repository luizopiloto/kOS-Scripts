//(XF-31b Canary) Propeller Boot Script
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Entry Point
function main
{    
    print "initializing...".
    local cpuok is false.
    local cpulist is 0.
    list processors in cpulist.
    for cpus in cpulist {if (cpus:volume:name = "xf31_prop"){set cpuok to true.}}
    if cpuok
    {
       compile "0:/xf31/prop.ks" to "xf31_prop:/prop.ksm".
       compile "0:/xf31/prstdby.ks" to "xf31_prop:/prstdby.ksm".
       return 0.
    }
    else 
    {
        print "Propeller CPU not found".
        return -1.
    }
    print "Initialization Ok.".
    return 0.
}

//Run
local result is main().
if (result = 0) runpath("prstdby.ksm").
else print "Program exited with code " + result.