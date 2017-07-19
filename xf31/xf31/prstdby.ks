//(XF-31b Canary) Propeller StandBy Script
//This file is distributed under the terms of the MIT license, (c) Luiz o Piloto

@lazyglobal off.

//Dotz <3
function prntDot
{
  parameter wt.
  parameter nod.
  parameter line.
  parameter col.
  local dotz is "".
  from {local i is 0.} until (i > nod) step {set i to i + 1.} do
  {
    print dotz at(col, line).
    set dotz to (dotz + ".").
    wait wt.
  }
}

//Entry Point
function main
{
    clearscreen.
    set terminal:width to 50.
    set terminal:height to 18.
    local lock plock to ship:partstagged("mport").
    local propready is false.
    until propready
    {
        if (plock:length > 0)
        {
            print ("StandBy   "):padright(50) at(0, 1).
            prntDot(1, 3, 1, 7).
        }
        else
        {
            set propready to true.
        }
    }
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) runpath("prop.ksm").
else print "Program exited with code " + result.