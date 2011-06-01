/*******************************************************************************
	DynamicMenuHolder.as
	
	This class is designed to function as a container for other DynamicMenu classes.
	It controlls things like menu states, transitions, and button commands.
	
	Use: Bind existing DynamicMenus via BindMenu(MenuID:String)
			-MenuID is the name of the DynamicMenu instance without the _mc suffix
			-All DynamicMenu instaces should have the _mc suffix
		
		Switch to a menu via SwitchToMenu(MenuID:String)
		
		Assign HandlePress(ButtonName:String) to a function to handle button presses.
	
	

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

import gfx.core.UIComponent;
import com.forecourse.DynamicMenu;

//Should totally check out forecourse.com :D
[InspectableList("InitialMenus")]
dynamic class com.forecourse.DynamicMenuHolder extends UIComponent{

	private var _CurrentMenu:DynamicMenu;
	private var _MenuAnimationStatus:String = "ready";
	
	private var bIntialized:Boolean = false;
	
	private var _NextDepth:Number = 10;
	
	public var HandePress:Function;
	
	private var _MenuMCs:Array = new Array();
	private var _InitialMenus:Array = new Array();
	
	//Current animation status of our opened Menu
	public function get MenuAnimationStatus():String { return _MenuAnimationStatus; }
	public function set MenuAnimationStatus(value:String):Void {
		_MenuAnimationStatus = value;
		if (value == "exited")
		{
			if (_CurrentMenu != undefined)
				_CurrentMenu.HandleMenuEnter();
		}
	}
	
	function BindMenu(MenuID:String)
	{
		var MenuMC:MovieClip = _root[MenuID+"_mc"];
		if (MenuMC.BindToParent != undefined)
		{
		    MenuMC.BindToParent(this);
		}
		_MenuMCs.push(MenuMC);
		MenuMC._visible = false;
	}
	
	function SwitchToMenu(MenuTitle:String)
	{
		var numMenus:Number = _MenuMCs.length;
		for (i = 0; i < numMenus; i++)
		{
			if (_MenuMCs[i]._name == MenuTitle+"_mc")
			{
				var bForceExited:Boolean = false;
				
				if (_CurrentMenu != _MenuMCs[i])
				{
					if (_CurrentMenu != undefined)
						_CurrentMenu.HandleMenuExit();
					else
						bForceExited = true;
						
					_CurrentMenu = _MenuMCs[i];
					
					if (bForceExited)
					    MenuAnimationStatus = "exited";
				}
			}
		}
	}

	
	function GetButtonMC(MenuTitle:String, ButtonName:String):MovieClip
	{
		var MenuMC:MovieClip = _root[MenuTitle+"_mc"];
		if (MenuMC != undefined)
		{
			var ButtonMC:MovieClip = MenuMC[ButtonName+"_mc"];
			if (ButtonMC != undefined)
				return ButtonMC;
		}
		return undefined;
	}
}
