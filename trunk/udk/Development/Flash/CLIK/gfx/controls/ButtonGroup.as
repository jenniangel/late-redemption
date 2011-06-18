﻿/**
 * The CLIK ButtonGroup component is used to manage sets of buttons. It allows one button in the set to be selected, and ensures that the rest are unselected. If the user selects another button in the set, then the currently selected button will be unselected. Any component that derives from the CLIK Button component (such as CheckBox and RadioButton) can be assigned a ButtonGroup instance.
 
	<b>Inspectable Properties</b>
 	The ButtonGroup does not have a visual representation on the Stage. Therefore no inspectable properties are available.
	
	<b>States</b>
	The ButtonGroup does not have a visual representation on the Stage. Therefore no states are associated with it.
	
	<b>Events</b>
	All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
	<li><i>type</i>: The event type.</li>
	<li><i>target</i>: The target that generated the event.</li></ul>
		
	The events generated by the ButtonBar component are listed below. The properties listed next to the event are provided in addition to the common properties.<ul>
	<li><i>change</i>: A new button from the group has been selected.</li><ul>
		<li><i>item</i>: The selected Button. CLIK Button type.</li>
		<li><i>data</i>: The data value of the selected Button. AS2 Object type.</li></ul></li>
	<li><i>itemClick</i>: A button in the group has been clicked.</li><ul>
		<li><i>item</i>: The Button that was clicked. CLIK Button type.</li></ul></li></ul>
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

import gfx.controls.Button;
import gfx.events.EventDispatcher;

class gfx.controls.ButtonGroup extends EventDispatcher {
	
// Constants:

// Public Properties:
	/** 
	 * The name of the ButtonGroup, specified by the {@code groupName} property on the subscribing Buttons.
	 * @see Button#groupName
	 */
	public var name:String = "buttonGroup";
	/** The current Button that is selected. Only a single Button can be selected at one time. */
	public var selectedButton:Button;
	/** The MovieClip container in which this ButtonGroup belongs. */
	public var scope:MovieClip;
	
// Private Properties:
	private var children:Array;
	

// Initialization:
	/**
	 * Create a new ButtonGroup. This class is usually instantiated by the first subscribing button, and stored in its parent MovieClip so that other buttons in the same movieClip, with the same {@code groupName} will all behave as a group.
	 * @param name The name of the ButtonGroup, specified by the {@code groupName} property of the subscribing buttons.
	 * @param scope The MovieClip scope that the ButtonGroup resides.
	 * @see Button#groupName
	 */
	public function ButtonGroup(name:String, scope:MovieClip) {
		super();
		this.name = name;
		this.scope = scope;
		children = [];
	}

// Public Methods:	
	/**
	 * The number of buttons in the group.
	 */
	public function get length():Number { return children.length; }
	
	/**
	 * Add a Button to group.  A Button can only be added once to a ButtonGroup, and can only exist in a single group at a time. Buttons will change the selection of a ButtonGroup by dispatching "select" and "click" events.
	 * @param button The Button instance to add to this group
	 */
	public function addButton(button:Button):Void {
		removeButton(button);
		children.push(button);
		if (button.selected) { setSelectedButton(button); }
		button.addEventListener("select", this, "handleSelect");
		button.addEventListener("click", this, "handleClick");
	}
	
	/**
	 * Remove a button from the group. If it the last button in the group, the button should clean up and destroy the ButtonGroup.
	 * @param button The Button instance to be removed from group.
	 */
	public function removeButton(button:Button):Void {
		var index:Number = indexOf(button);
		if (index > -1) {
			children.splice(index, 1);
			button.removeEventListener("select", this, "handleSelect");
			button.removeEventListener("click", this, "handleClick");
		}
		if (selectedButton == button) { selectedButton = null; }
	}
	
	/**
	 * Find the index of a button in the ButtonGroup. Buttons are indexed in the order that they are added.
	 * @param button The button to find in the ButtonGroup
	 * @returns The index of the specified Button. -1 if it is not found.
	 */
	public function indexOf(button:Button):Number {
		var l:Number = length;
		if (l == 0) { return -1; }
		for (var i:Number=0; i<length; i++) {
			if (children[i] == button) { return i; }
		}
		return -1;
	}
	
	/**
	 * Find a button at a specified index in the ButtonGroup. Buttons are indexed in the order that they are added.
	 * @param index Index in the ButtonGroup of the Button.
	 * @returns The button at the specified index. null if there is no button at that index.
	 */
	public function getButtonAt(index:Number):Button {
		return children[index];
	}
	
	/**
	 * The {@code data} property of the currently selected button.
	 */
	public function get data():Object { return selectedButton.data; }
	
	/**
	 * Sets the specified button to the {@code selectedButton}. The selected property of the previous selected Button will be set to {@code false}. If {@code null} is passed to this method, the current selected Button will be deselected, and the {@code selectedButton} property set to {@code null}. 
	 * @param button The button instance to select.
	 * @see #selectedButton
	 */
	public function setSelectedButton(button:Button):Void {
		if (selectedButton == button || (indexOf(button) == -1 && button != null)) { return; } 
		if (selectedButton != null && selectedButton._name != null) { // If the clip is removed, it may not be null. Check the name as well.
			selectedButton.selected = false;
		}
		selectedButton = button;
		if (selectedButton == null) { return; }
		selectedButton.selected = true;
		dispatchEvent({type:"change", item:selectedButton, data:selectedButton.data});
	}
	
	/** @exclude */
	public function toString():String {
		return "[Scaleform RadioButtonGroup " + name + "]";
	}
	
	
// Private Methods:
	/**
	 * The "selected" state of one of the buttons in the group has changed. If the button is selected, it will become the new {@code selectedButton}. If it is not, the selectedButton in the group is set to {@code null}.
	 */
	private function handleSelect(event:Object):Void {
		if (event.target.selected) {
			setSelectedButton(event.target);
		} else {
			setSelectedButton(null);
		}
	}
	
	/**
	 * A button in the group has been clicked. The button will be set to the {@code selectedButton}.
	 */
	private function handleClick(event:Object):Void {
		dispatchEvent({type:"itemClick", item:event.target});
		setSelectedButton(event.target);
	}

}