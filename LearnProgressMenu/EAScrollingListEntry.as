import mx.controls.TextInput;

class EAScrollingListEntry extends MovieClip
{
	var entry:MovieClip;
	var clickMeasure:Number;

	function EAScrollingListEntry()
	{
		super();
	}

	function OnMouseRollover()
	{
		this.highlightEntry();
		_parent.SetSelection(this);
	}
	function OnMouseRollout()
	{
		this.clear();
	}
	function OnMousePress()
	{
	    if (clickMeasure - (clickMeasure = getTimer()) + 500 > 0
	    	&& this.entry._textLabel.hitTest(_root._xmouse, _root._ymouse))
	    {
            //doubleclick

			_parent.SecureFocus();
			this.clear();
	        this.entry._textLabel.editable = true;
			this.entry._textLabel.setFocus();
			this.entry._textLabel.setStyle("backgroundColor", 0x0a0a0a); //Set cursor to blink at end instead...

			this.entry._textLabel.hPosition = 0;
			this.entry._textLabel.keyDown = this.HandleTextInput;
		}
		else //singleclick
		{
		    Selection.setFocus(_root._falseFocus); //prevent stray cursor
			_parent.InterruptFocus(this);
		}
	}
	function HandleTextInput():Void
	{
	    if (Key.getCode() == Key.ENTER || Key.getCode() == Key.TAB || Key.getCode() == Key.ESCAPE)
	    {
	    	var thisLabel:TextInput = TextInput(this); //have to cast this explicitly or it wont work
	    	
	    	Selection.setFocus(null);
	        thisLabel.editable = false;

			thisLabel.setStyle("backgroundColor", undefined);
			thisLabel.hPosition = 0;
			thisLabel.invalidate();

	        _root._scrollingList.ReleaseFocus();
			_parent._parent._textLabel.keyDown = null;
	    }
	}

	function StopTextInput()
	{
    	Selection.setFocus(null);

    	var thisLabel:TextInput = this.entry._textLabel;

		thisLabel.setStyle("backgroundColor", undefined);
        thisLabel.editable = false;
		thisLabel.hPosition = 0;
		thisLabel.invalidate();
	}

	function highlightEntry()
	{
		var cornerRadius:Number = 14;
		var lineThickness:Number = 10;
		var lineColor:Number = 0x333333;
		var lineAlpha:Number = 30;
		var boxHeight:Number = this._height;
		var boxWidth:Number = this._width;
		var baseX:Number = 0;
		var baseY:Number = 0;

		for (var i = lineThickness; i > 0; i--)
		{
			with (this)
			{
				beginFill();
					lineStyle(1, multiplyRGB(lineColor, i / lineThickness), lineAlpha);
					moveTo(cornerRadius, baseY);
					lineTo(boxWidth - cornerRadius, baseY);
					curveTo(boxWidth, baseY, boxWidth, cornerRadius);
					lineTo(boxWidth, cornerRadius);
					lineTo(boxWidth, boxHeight - cornerRadius);
					curveTo(boxWidth, boxHeight, boxWidth - cornerRadius, boxHeight);
					lineTo(boxWidth - cornerRadius, boxHeight);
					lineTo(cornerRadius, boxHeight);
					curveTo(baseX, boxHeight, baseX, boxHeight - cornerRadius);
					lineTo(baseX, boxHeight - cornerRadius);
					lineTo(baseX, cornerRadius);
					curveTo(baseX, baseY, cornerRadius, baseY);
					lineTo(cornerRadius, baseY);
				endFill();
			}
			boxHeight -= 1;
			boxWidth -= 1;
			baseX += 1;
			baseY += 1;
		}
	}

	function multiplyRGB(a_color:Number, a_mult:Number):Number
	{
		var colorB:Number = (a_color >> 16) & 0xFF;
		var colorG:Number = (a_color >> 8)  & 0xFF;
		var colorR:Number = (a_color >> 0)  & 0xFF;

		colorB = Math.min(Math.floor(colorB * a_mult), 0xFF);
		colorG = Math.min(Math.floor(colorG * a_mult), 0xFF); //cap at 0xFF
		colorR = Math.min(Math.floor(colorR * a_mult), 0xFF);

		var outColor:Number = (colorB << 16) | (colorG << 8) | (colorR << 0);

		return outColor;
	}
}