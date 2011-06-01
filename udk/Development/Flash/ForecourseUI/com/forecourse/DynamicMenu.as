/*******************************************************************************
	DynamicMenu.as
	
	This class is designed to function as a user-friendly way to make a series
	of sub-menus without having to re-write code or manually making each
	menu in Flash.

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
import mx.utils.Delegate;

//should totally check out forecourse.com :D
[InspectableList("MenuTitle","FirstButtonY","ButtonSpacing","Buttons","AnimationType")]
dynamic class com.forecourse.DynamicMenu extends UIComponent{

	private var _MenuTitle:String = "Menu Title";
	private var _FirstButtonY:Number = 0;
	private var _ButtonSpacing:Number = 65;
	private var _Buttons:Array;
	
	
	//Animation stuff
	private var _FirstButtonStartY:Number = 800;
	private var _ButtonSpacingStart:Number = 600;
	private var _AnimationFrames:Number = 45;
	private var _AnimationType:String;
	private var HandleAnimation:Function;
	//HandleMovieAnimation is essentially an assignable onEnterFrame
	public var HandleMovieAnimation:Function;
	
	private var _ParentMenuHolder:MovieClip;
	
	private var _ButtonMCs:Array;

	public var MenuTitle_txt:TextField;
	

	function DynamicMenu() {
		var numButtons:Number = _Buttons.length;
		var newButton:MovieClip;
		
		_ButtonMCs = new Array();
		
		for (var i = 0; i < numButtons; i++)
		{
			newButton = createInstance(this,"DynamicMenu_Button",_Buttons[i]+"_mc",this.getNextHighestDepth(),{_x:0,_y:_FirstButtonY + _ButtonSpacing*i});
			this._ButtonMCs.push(newButton);
			
			if (newButton.textField != undefined) newButton.textField.text = _Buttons[i];
			newButton.addEventListener("click",Delegate.create(this,HandlePress));
		}
		
		this.onEnterFrame = Delegate.create(this,HandleEnterFrame);
	}
  
	[Inspectable(name="MenuTitle", defaultValue="Menu Title")]
	public function get MenuTitle():String { return _MenuTitle; }
	public function set MenuTitle(value:String):Void {
		_MenuTitle = value;
		if (MenuTitle_txt != null)
		{
			MenuTitle_txt.text = _MenuTitle;
		}
		
	}
	
	[Inspectable(name="FirstButtonY", defaultValue="100")]
	public function get FirstButtonY():Number { return _FirstButtonY; }
	public function set FirstButtonY(value:Number):Void {
		_FirstButtonY = value;
	}
	
	[Inspectable(name="ButtonSpacing", defaultValue="65")]
	public function get ButtonSpacing():Number { return _ButtonSpacing; }
	public function set ButtonSpacing(value:Number):Void {
		_ButtonSpacing = value;
	}
  
  	[Inspectable(name="Buttons", type="Array")]
	public function get Buttons():Array { return _Buttons; }
	public function set Buttons(value:Array):Void {
		_Buttons = value;
	}
	
	[Inspectable(name="AnimationType", type="string", enumeration="FlyIn,None", defaultValue="FlyIn")]
	public function get AnimationType():String { return _AnimationType; }
	public function set AnimationType(value:String):Void {
		_AnimationType = value;
	}
	
	public function get ParentMenuHolder():MovieClip { return _ParentMenuHolder; }
	public function set ParentMenuHolder(value:MovieClip):Void {
		_ParentMenuHolder = value;
	}
	
	function HandlePress(eventObj) {
		if (ParentMenuHolder.HandlePress != undefined)
		{
			
		    ParentMenuHolder.HandlePress(eventObj.invokedButton._name.substr(0,eventObj.invokedButton._name.length-3));
		}
	}
	
	
	//Work around to have a onEnterFrame within a class.
	//Assigned to onEnterFrame via delegate
	function HandleEnterFrame()
	{
		if (_ParentMenuHolder.MenuAnimationStatus != "ready")
		{
			if (HandleAnimation != undefined)
				HandleAnimation();
		}
		if (HandleMovieAnimation != undefined)
			HandleMovieAnimation();
	}
	
	function HandleMenuEnter()
	{
		this._visible = true;
		switch (AnimationType)
		{
			case "FlyIn":
				var numButtons:Number = _ButtonMCs.length;
				var newButton:MovieClip;
				for (i = 0; i < numButtons; i++)
				{
					_ButtonMCs[i]._y = _FirstButtonStartY + _ButtonSpacingStart*i
				}
			    this.HandleAnimation = Delegate.create(this,FlyInAnimation);
				_ParentMenuHolder.MenuAnimationStatus = "entry";
				break;
			case "None":
			default:
				this._visible = false;
				_ParentMenuHolder.MenuAnimationStatus = "ready";
		}
	}
	
	function HandleMenuExit()
	{
		_ParentMenuHolder.MenuAnimationStatus = "exiting";
		switch (AnimationType)
		{
			case "FlyIn":
			    this.HandleAnimation = Delegate.create(this,FlyOutAnimation);
				break;
			case "None":
			default:
				this._visible = false;
				_ParentMenuHolder.MenuAnimationStatus = "exited";
		}
	}
	
	//Returns true if our animation is done.
	function FlyInAnimation():Boolean
	{
		var numButtons:Number = _ButtonMCs.length;
		var bDone:Boolean = true;

		for (var i = 0; i < numButtons; i++)
		{
			if (this._ButtonMCs[i]._y > _FirstButtonY + _ButtonSpacing*i)
			{
				this._ButtonMCs[i]._y -= ((_FirstButtonStartY + _ButtonSpacingStart*i) - (_FirstButtonY + _ButtonSpacing*i)) / _AnimationFrames;
				bDone = false;
			}
			else
				this._ButtonMCs[i]._y = _FirstButtonY + _ButtonSpacing*i;
		}
		if (bDone)
		{
			this.HandleAnimation = undefined;
			
			if (_ParentMenuHolder.MenuAnimationStatus != undefined)
				_ParentMenuHolder.MenuAnimationStatus = "ready";
		}
		
		return bDone;
	}
	
	function FlyOutAnimation():Boolean
	{
		var numButtons:Number = _ButtonMCs.length;
		var bDone:Boolean = true;
		for (i = 0; i < numButtons; i++)
		{
			if (this._ButtonMCs[i]._y < _FirstButtonStartY + _ButtonSpacingStart*i)
			{
				this._ButtonMCs[i]._y += ((_FirstButtonStartY + _ButtonSpacingStart*i) - (_FirstButtonY + _ButtonSpacing*i)) / _AnimationFrames;
				bDone = false;
			}
		}
		if (bDone)
		{
			this._visible = false;
			this.HandleAnimation = undefined;
			
			if (_ParentMenuHolder.MenuAnimationStatus != undefined)
				_ParentMenuHolder.MenuAnimationStatus = "exited";
		}
		
		return bDone;
	}
	
	function BindToParent(MenuHolder_mc:MovieClip)
	{
		this._x = MenuHolder_mc._x;
		this._y = MenuHolder_mc._y;
		ParentMenuHolder = MenuHolder_mc;
		
		var numButtons:Number = _ButtonMCs.length;
		var bDone:Boolean = true;
		for (i = 0; i < numButtons; i++)
		{
			_ButtonMCs[i]._x = x;
			
		}
		
	}
  

}