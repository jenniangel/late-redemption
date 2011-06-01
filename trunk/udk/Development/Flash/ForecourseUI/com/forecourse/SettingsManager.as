/*******************************************************************************
	SettingsManager.as
	
	This ActionScript class is designed to encapsulate all our code in regards to
	storing and manipulating data used for game settings, such as resolution. It
	has various points of access for displaying data to a GUI of some kind.

	Copyright (c) 2010, Allar

	This file is part of Forecourse.

	To use any part of Forecourse commercially, please contact Michael Allar
	at allar@michaelallar.com or see <http://www.forecourse.com>

    Forecourse is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Forecourse.  if not, see <http://www.gnu.org/licenses/>.

*******************************************************************************/

import flash.external.ExternalInterface;

dynamic class com.forecourse.SettingsManager
{
	private var _ResIndex:Number = 0;
	private var _ResStartIndex:Number = 0;
	
	var ResolutionPrefix:String = "Resolution: ";
	
	var ResArray:Array = new Array("640x480","800x600","1024x768","1152x864","1280x720","1280x768","1280x800","1280x960","1280x1024","1400x900","1600x1200","1680x1050","1920x1080","1920x1200");
	var CustomResolution:String;
	
	var Resolution_txt:TextField;
	
	//Called from game to set our initial resolution setting
	function SetResolutionByString(newRes:String):Void
	{
		for (i = 0; i < ResArray.length; i++)
		{
			if (ResArray[i] == newRes)
			{
				_ResIndex = i;
				_ResStartIndex = i;
				UpdateResolutionText();
				return;
			}
		}
		
		ForceResolutionText(newRes);
		
	}
	
	//Updates our button's textField
	function UpdateResolutionText()
	{
		if(Resolution_txt != undefined)
		{
			Resolution_txt.text = ResolutionPrefix + ResArray[ResIndex];
		}
	}
	
	function ForceResolutionText(newRes:String)
	{
		//Custom res
		_ResIndex = -1;
		_ResStartIndex = -1;
		
		CustomResolution = newRes;
		
		if (Resolution_txt != undefined)
			Resolution_Txt.text = ResolutionPrefix + CustomResolution;	
	}
	
	function GetResolutionText():String
	{
		if (_ResIndex != -1)
			return ResArray[ResIndex];
		
		return CustomRes;
	}
	
	function ApplyChanges()
	{
		if (_ResIndex != _ResStartIndex)
			ExternalInterface.call("FlashToConsole", "setres " + GetResolutionText());
	}
	
		
	public function get ResIndex():Number { return _ResIndex; }
	public function set ResIndex(value:Number):Void {
		if (value < 0)
			_ResIndex = 0;
		else if (value >= ResArray.length)
			_ResIndex = ResArray.length-1;
		else
			_resIndex = value;
			
		UpdateResolutionText();
	}
	
	function ShiftResIndex(resOffset:Number)
	{
		var NewResIndex:Number = _ResIndex + resOffset;
		
		if (NewResIndex < 0)
			_ResIndex = ResArray.length + NewResIndex;
		else if (NewResIndex >= ResArray.length)
			_ResIndex = NewResIndex-ResArray.length;
		else
			_ResIndex = NewResIndex;
			
		UpdateResolutionText();
	}


}