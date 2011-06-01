﻿/**
 * The CheckBox is a Button component that is set to toggle the selected state when clicked. CheckBoxes are used to display and change a true/false (Boolean) value. It is functionally equivalent to the ToggleButton, but sets the toggle property implicitly.
 
 	<b>Inspectable Properties</b>
	Since it derives from the Button control, the CheckBox contains the same inspectable properties as the Button with the omission of the toggle and disableFocus properties.<ul>
	<li><i>label</i>: Sets the label of the Button.</li>
	<li><i>visible</i>: Hides the button if set to false.</li>
	<li><i>disabled</i>: Disables the button if set to true.</li>
	<li><i>disableFocus</i>: By default buttons receive focus for user interactions. Setting this property to true will disable focus acquisition.</li>
	<li><i>disableConstraints</i>: The Button component contains a constraints object that determines the placement and scaling of the textField inside of the button when the component is resized. Setting this property to true will disable the constraints object. This is particularly useful if there is a need to resize or reposition the button's textField via a timeline animation and the button component is never resized. If not disabled, the textField will be moved and scaled to its default values throughout its lifetime, thus nullifying any textField translation/scaling tweens that may have been created in the button's timeline.</li>
	<li><i>data</i>: Custom string that can be attached to the component as seperate data than the CheckBox's label.</li>
	<li><i>selected</i>: Checks (or selects) the CheckBox when set to true.</li>
	<li><i>autoSize</i>: Determines if the button will scale to fit the text that it contains and which direction to align the resized button. Setting the autoSize property to {@code autoSize="none"} will leave its current size unchanged.</li>
	<li><i>enableInitCallback</i>: If set to true, _global.CLIK_loadCallback() will be fired when a component is loaded and _global.CLIK_unloadCallback will be called when the component is unloaded. These methods receive the instance name, target path, and a reference the component as parameters.  _global.CLIK_loadCallback and _global.CLIK_unloadCallback should be overriden from the game engine using GFx FunctionObjects.</li>
	<li><i>soundMap</i>: Mapping between events and sound process. When an event is fired, the associated sound process will be fired via _global.gfxProcessSound, which should be overriden from the game engine using GFx FunctionObjects.</li></ul>
	
	<b>States</b>
	Due to its toggle property, the CheckBox requires another set of keyframes to denote the selected state. These states include <ul>
	<li>an up or default state.</li>
	<li>an over state when the mouse cursor is over the component, or when it is focused.</li>
	<li>a down state when the button is pressed.</li>
	<li>a disabled state.</li>
	<li>a selected_up or default state.</li>
	<li>a selected_over state when the mouse cursor is over the component, or when it is focused.</li>
	<li>a selected_down state when the button is pressed.</li>
	<li>a selected_disabled state.</li></ul>

	These are the minimal set of keyframes that should be in a CheckBox. The extended set of states and keyframes supported by the Button component, and consequently the CheckBox component, are described in the Getting Started with CLIK Buttons document.	
	
	<b>Events</b>
	All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
	<li><i>type</i>: The event type.</li>
	<li><i>target</i>: The target that generated the event.</li></ul>
		
	The events generated by the CheckBox component are listed below. The properties listed next to the event are provided in addition to the common properties.<ul>
	<li><i>show</i>: The visible property has been set to true at runtime.</li>
	<li><i>hide</i>: The visible property has been set to false at runtime.</li>
	<li><i>focusIn</i>: The component has received focus.</li>
	<li><i>focusOut</i>: The component has lost focus.</li>
	<li><i>select</i>: The component's selected property has changed.<ul>
		<li><i>selected</i>: The selected property of the Button. Boolean type.</li></ul></li>
	<li><i>stateChange</i>: The button's state has changed.<ul>
		<li><i>state</i>: The Button's new state. String type. Values "up", "over", "down", etc.</li></ul></li>
	<li><i>rollOver</i>: The mouse cursor has rolled over the button.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>rollOut</i>: The mouse cursor has rolled out of the button.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>press</i>: The button has been pressed.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments).Number type. Values 0 to 3. </li></ul></li>
	<li><i>doubleClick</i>: The button has been double clicked. Only fired when the {@link Button.doubleClickEnabled} property is true.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>click</i>: The button has been clicked.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>dragOver</i>: The mouse cursor has been dragged over the button (while the left mouse button is pressed).<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>dragOut</i>: The mouse cursor has been dragged out of the button (while the left mouse button is pressed).<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li>
	<li><i>releaseOutside</i>: The mouse cursor has been dragged out of the button and the left mouse button has been released.<ul>
		<li><i>controllerIdx</i>: The index of the mouse cursor used to generate the event (applicable only for multi-mouse-cursor environments). Number type. Values 0 to 3. </li></ul></li></ul>
 
 */

/**********************************************************************
 Copyright (c) 2009 Scaleform Corporation. All Rights Reserved.

 Portions of the integration code is from Epic Games as identified by Perforce annotations.
 Copyright © 2010 Epic Games, Inc. All rights reserved.
 
 Licensees may use this file in accordance with the valid Scaleform
 License Agreement provided with the software. This file is provided 
 AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE WARRANTY OF DESIGN, 
 MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.
**********************************************************************/

import flash.external.ExternalInterface; 
import gfx.controls.Button;

[InspectableList("disabled", "visible", "labelID", "selected", "data", "disableConstraints", "enableInitCallback", "autoSize", "soundMap")]
class gfx.controls.CheckBox extends Button {
	
// Initialization:
	/**
	 * The constructor is called when a CheckBox or a sub-class of CheckBox is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend CheckBox, ensure that a {@code super()} call is made made first in the constructor.
	 */
	public function CheckBox() {
		super();
	}
	
	/** @exclude */
	public function toString():String {
		return "[Scaleform CheckBox " + _name + "]";
	}

// Private Methods:
	private function configUI():Void {
		super.configUI();
		toggle = true;
	}

}