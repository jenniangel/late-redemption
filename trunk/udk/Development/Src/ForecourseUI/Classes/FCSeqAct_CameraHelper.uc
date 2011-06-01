/*******************************************************************************
	FCSeqAct_CameraHelper

	This kismet action allows an easier way to create camera movement
	without the need for insane kismet spagetti and annoyance.

	Creation date: 06/06/2010 13:57
	Copyright (c) 2010, Allar

	This file is part of ForecourseUI.

	To use any part of Forecourse commercially, please contact Michael Allar
	at allar@michaelallar.com or see <http://www.forecourse.com>

    ForecourseUI is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ForecourseUI.  if not, see <http://www.gnu.org/licenses/>.

*******************************************************************************/

class FCSeqAct_CameraHelper extends SequenceAction;

enum ECameraStatus
{
    CAMERA_Idle,
    CAMERA_Reversing,
    CAMERA_Moving,
};

var ECameraStatus CameraStatus;
var int CurrentMenu;

event Activated()
{
    local int i;
    local int Menu;

    Menu = -1;
    if (CameraStatus == CAMERA_Idle)
    {
        for (i = 0; i < 10; i++)
        {
            if (InputLinks[i].bHasImpulse)
            {
               Menu = i;
               break;
            }
        }

        `log("Idle: Inputted menu = " $ Menu);

        if (Menu != -1)
        {
            OutputLinks[1].bHasImpulse=true;
            if (CurrentMenu != -1)
            {
               OutputLinks[2+(CurrentMenu*2)+1].bHasImpulse = true;
               CameraStatus = CAMERA_Reversing;
               CurrentMenu = Menu;
               return;
            }
            else
            {
               OutputLinks[2+(Menu*2)].bHasImpulse = true;
               CameraStatus = CAMERA_Moving;
               CurrentMenu = Menu;
               return;
            }
        }
    }
    else if (CameraStatus == CAMERA_Moving)
    {
        if (InputLinks[10].bHasImpulse)
        {
            OutputLinks[0].bHasImpulse = true;
            CameraStatus = CAMERA_Idle;
        }
    }
    else if (CameraStatus == CAMERA_Reversing)
    {
        if (InputLinks[11].bHasImpulse)
        {
            OutputLinks[2+(CurrentMenu*2)].bHasImpulse = true;
            CameraStatus = CAMERA_Moving;
        }
    }

}

defaultProperties
{
    ObjName="Camera Helper"
	ObjCategory="Forecourse"

    bCallHandler=false
	bAutoActivateOutputLinks=false

	CameraStatus=CAMERA_Idle
	CurrentMenu=-1

    InputLinks(0)=(LinkDesc="Menu 1")
    InputLinks(1)=(LinkDesc="Menu 2")
    InputLinks(2)=(LinkDesc="Menu 3")
    InputLinks(3)=(LinkDesc="Menu 4")
    InputLinks(4)=(LinkDesc="Menu 5")
    InputLinks(5)=(LinkDesc="Menu 6")
    InputLinks(6)=(LinkDesc="Menu 7")
    InputLinks(7)=(LinkDesc="Menu 8")
    InputLinks(8)=(LinkDesc="Menu 9")
    InputLinks(9)=(LinkDesc="Menu 10")
    InputLinks(10)=(LinkDesc="Completed")
    InputLinks(11)=(LinkDesc="Reversed")

    OutputLinks(0)=(LinkDesc="Idle")
    OutputLinks(1)=(LinkDesc="Idle Stop")
    OutputLinks(2)=(LinkDesc="Menu 1")
    OutputLinks(3)=(LinkDesc="Menu 1 Reverse")
    OutputLinks(4)=(LinkDesc="Menu 2")
    OutputLinks(5)=(LinkDesc="Menu 2 Reverse")
    OutputLinks(6)=(LinkDesc="Menu 3")
    OutputLinks(7)=(LinkDesc="Menu 3 Reverse")
    OutputLinks(8)=(LinkDesc="Menu 4")
    OutputLinks(9)=(LinkDesc="Menu 4 Reverse")
    OutputLinks(10)=(LinkDesc="Menu 5")
    OutputLinks(11)=(LinkDesc="Menu 5 Reverse")
    OutputLinks(12)=(LinkDesc="Menu 6")
    OutputLinks(13)=(LinkDesc="Menu 6 Reverse")
    OutputLinks(14)=(LinkDesc="Menu 7")
    OutputLinks(15)=(LinkDesc="Menu 7 Reverse")
    OutputLinks(16)=(LinkDesc="Menu 8")
    OutputLinks(17)=(LinkDesc="Menu 8 Reverse")
    OutputLinks(18)=(LinkDesc="Menu 9")
    OutputLinks(19)=(LinkDesc="Menu 9 Reverse")
    OutputLinks(20)=(LinkDesc="Menu 10")
    OutputLinks(21)=(LinkDesc="Menu 10 Reverse")

}

