/*******************************************************************************
	FCGFxUIFrontEnd_MainMenu

	This class extends from GFxMoviePlayer to give some functionality to the
	base Scaleform Movie Player so we can do fancy sophisticated things in our
	own flash menu.

	Creation date: 26/05/2010 04:26
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

class FCGFxUIFrontEnd_MainMenu extends GFxMoviePlayer;

function bool Start(optional bool StartPaused = false)
{
    super.Start();
    Advance(0);

    return true;
}

function SetUpSettings()
{
     local GameViewportClient GVC;
     local vector2d xy;

     GVC = GetGameViewportClient();
     GVC.GetViewportSize(xy);

    SendResolution(int(xy.x)$"x"$int(xy.y));
}

function SendResolution(string newRes)
{
     ActionScriptVoid("SetResolutionByString");
}

function FlashToConsole(string consoleCommand)
{
    local GameViewportClient GVC;

     GVC = GetGameViewportClient();
     GVC.ConsoleCommand(consoleCommand);
}

