//(XF-31b Canary) Plane Boot Script
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Entry Point
function main
{    
    print "initializing...".
    local cpuok is false.
    local cpulist is 0.
    list processors in cpulist.
    for cpus in cpulist {if (cpus:volume:name = "xf31_main"){set cpuok to true.}}
    if cpuok
    {
       compile "0:/xf31/xf31.ks" to "xf31_main:/xf31.ksm".
       compile "0:/xf31/stdby.ks" to "xf31_main:/stdby.ksm".
       return 0.
    }
    else 
    {
        print "XF31 CPU not found".
        return -1.
    }
    print "Initialization Ok.".
    return 0.
}

//Run
local result is main().
if (result = 0) runpath("stdby.ksm").
else print "Program exited with code " + result.