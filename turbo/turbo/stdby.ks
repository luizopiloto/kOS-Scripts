//(Krakentech Turbo Helicopter Software) StandBy module
//This file is distributed under the terms of the MIT license, (c)Luiz o Piloto

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
    set terminal:width to 40.
    set terminal:height to 8.
    local lock plock to ship:partstagged("plock").
    local rotorready is false.
    until rotorready
    {
        if (plock:length > 1)
        {
            print ("StandBy   "):padright(40) at(0, 1).
            prntDot(1, 3, 1, 7).
        }
        else
        {
            set rotorready to true.
        }
    }
    return 0.
}

//Run
local result is main().
clearscreen.
if (result = 0) runpath("firmware.ksm").
else print "Program exited with code " + result.