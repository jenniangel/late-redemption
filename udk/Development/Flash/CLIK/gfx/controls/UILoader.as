﻿/**
 * The CLIK UILoader loads an external SWF/GFX or image using only the path. UILoaders also support auto-sizing of the loaded asset to fit in its bounding box. Asset loading is asynchronous if both GFx and the platform running it has threading support.
 
	<b>Inspectable Properties</b>
	A MovieClip that derives from the UILoader component will have the following inspectable properties:<ul>
	<li><i>visible</i>: Hides the component if set to false.</li>
	<li><i>autoSize</i>: If set to true, sizes the loaded to content to fit in the UILoader’s bounds.</li>
	<li><i>maintainAspectRatio</i>: If true, the loaded content will be fit based on its aspect ratio inside the UILoader’s bounds. If false, then the content will be stretched to fit the UILoader bounds.</li>
	<li><i>source</i>: The SWF/GFX or image filename to load.</li>
    <li><i>enableInitCallback</i>: If set to true, _global.CLIK_loadCallback() will be fired when a component is loaded and _global.CLIK_unloadCallback will be called when the component is unloaded. These methods receive the instance name, target path, and a reference the component as parameters.  _global.CLIK_loadCallback and _global.CLIK_unloadCallback should be overriden from the game engine using GFx FunctionObjects.</li></ul>

	<b>States</b>
	There are no states for the UILoader component. If a SWF/GFX is loaded into the UILoader, then it may have its own states. 
	
	<b>Events</b>
	All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
	<li><i>type</i>: The event type.</li>
	<li><i>target</i>: The target that generated the event.</li></ul>
		
	The events generated by the UILoader component are listed below. The properties listed next to the event are provided in addition to the common properties.<ul>
	<li><i>show</i>: The component’s visible property has been set to true at runtime.</li>
	<li><i>hide</i>: The component’s visible property has been set to false at runtime.</li>
	<li><i>progress</i>: Content is in the process of being loaded regardless whether the content can or cannot be loaded. This event will be fired continuously until either a) the content is loaded or b) the loading timeout has been reached.<ul>
		<li><i>loaded</i>: The percentage of data loaded. This property’s value is between 0 and 100.</li></ul></li>
	<li><i>complete</i>: Content loading has been completed.</li>
	<li><i>ioError</i>: Content specified in the source property could not be loaded.</li></ul>

 */

/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.

 Portions of the integration code is from Epic Games as identified by Perforce annotations.
 Copyright 2010 Epic Games, Inc. All rights reserved.
 
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

/*
 An IOError will be dispatched after the timeout, even if the player catches it sooner, since we can not supress it.
*/
import gfx.core.UIComponent;

[InspectableList("visible", "autoSize", "source", "maintainAspectRatio", "enableInitCallback")]
class gfx.controls.UILoader extends UIComponent {
	
// Constants:

// Public Properties:
	/** The total bytes loaded in the current load */
	public var bytesLoaded:Number;
	/** The current total bytes in the current load. */
	public var bytesTotal:Number;
	
// Private Properties:
	private var _source:String;
	private var _maintainAspectRatio:Boolean = true;
	private var _autoSize:Boolean = true;
	private var _visiblilityBeforeLoad:Boolean = true;
	private var loader:MovieClipLoader;
	private var _loadOK:Boolean = false;
	private var _sizeRetries:Number = 0;
	
// UI Elements:
	private var bg:MovieClip;
	private var contentHolder:MovieClip;
	

// Initialization:
	/**
	 * The constructor is called when a UILoader or a sub-class of UILoader is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend UILoader, ensure that a {@code super()} call is made first in the constructor.
	 */
	public function UILoader() { super(); }

// Public Methods:
	/**
	 * Automatically scale the content to fit the container.
	 */
	[Inspectable(defaultValue="true")]
	public function get autoSize():Boolean { return _autoSize; }
	public function set autoSize(value:Boolean) {
		_autoSize = value;
		invalidate();
	}
	
	/**
	 * Set the source of the content to be loaded.
	 */
	[Inspectable(defaultValue="")]
	public function get source():String { return _source; }
	public function set source(value:String):Void { 
		if (value == "") { return; } 
        if (_source == value) { return; }
		load(value);
	}
	
	/**
	 * Maintain the original content's aspect ration when scaling it. If {@code autoSize} is {@code false}, this property is ignored.
	 */
	[Inspectable(defaultValue="true")]
	public function get maintainAspectRatio():Boolean { return _maintainAspectRatio; }
	public function set maintainAspectRatio(value:Boolean):Void {
		_maintainAspectRatio = value;
		invalidate();
	}
	
	/** 
	 * A read-only property that returns the loaded content of the UILoader.
	 */
	public function get content():MovieClip { 
		return contentHolder;
	}
	
	/**
	 * A read-only property that returns the percentage that the content is loaded. The percentage is normalized to a 0-100 range.
	 */
	public function get percentLoaded():Number {
		if (bytesTotal == 0 || _source == null) { return 0; }
		return bytesLoaded / bytesTotal * 100;
	}
	
	/**
	 * Unload the currently loaded content, or stop any pending or active load.
	 */
	public function unload():Void {
		onEnterFrame = null;
		if (contentHolder != null) { 
			visible = _visiblilityBeforeLoad;
			loader.unloadClip(contentHolder);
			contentHolder.removeMovieClip();
			contentHolder = null;
		}
		_source = undefined;
		_loadOK = false;
		_sizeRetries = 0;
	}
	
	/** @exclude */
	public function toString():String {
		return "[Scaleform UILoader " + _name + "]";
	}
	
	
// Private Methods:
	private function configUI():Void {
		super.configUI();
		initSize();
		bg.swapDepths(100); 
		bg.removeMovieClip();
		if (!contentHolder && _source) { load(_source); }
	}	

	private function load(url:String):Void {
		if (url == "") { return; }
		unload();				
		_source = url;
		if (!initialized) { return; }
		_visiblilityBeforeLoad = visible;
		visible = false;
		contentHolder = createEmptyMovieClip("contentHolder", 1);
		loader = new MovieClipLoader();
		loader.addListener(this);
		loader.loadClip(_source, contentHolder);
		onEnterFrame = checkProgress;	
	}
	
	private function draw():Void {		
		if (!_loadOK) { return; }
		contentHolder._xscale = contentHolder._yscale = 100;		
		if (!_autoSize) { 
			visible = _visiblilityBeforeLoad;
			return; 
		}
		if (contentHolder._width <= 0) { 
			if (_sizeRetries < 10) { 
				_sizeRetries++;
				invalidate(); 
			}
			else { trace("Error: " + targetPath(this) + " cannot be autoSized because content _width is <= 0!"); }
			return; 
		}
		if (_maintainAspectRatio) { 
			contentHolder._xscale = contentHolder._yscale = Math.min(height/contentHolder._height,width/contentHolder._width) * 100;
			contentHolder._x = (__width-contentHolder._width>>1);
			contentHolder._y = (__height-contentHolder._height>>1);
		} else {
			contentHolder._width = __width;
			contentHolder._height = __height;
		}
		visible = _visiblilityBeforeLoad;
	}
	
	private function onLoadError():Void {
		visible = _visiblilityBeforeLoad;
		dispatchEvent({type:"ioError"});
	}
	
	private function onLoadComplete():Void {
		onEnterFrame = null;
		_loadOK = true;
		draw(); // Use draw instead of invalidate to avoid flicker	
		dispatchEvent({type:"complete"});
	}
	
	private function checkProgress():Void {		
		var progress:Object = loader.getProgress(contentHolder);		
		bytesLoaded = progress.bytesLoaded;
		bytesTotal = progress.bytesTotal;
		if (bytesTotal < 5) { return; }			
		dispatchEvent({type:"progress", loaded:percentLoaded});		
	}
}
