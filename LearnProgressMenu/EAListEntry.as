class EAListEntry extends MovieClip
{
	private var Origin:Number = 0;
	private var Target:Number = 0;
	private var Current:Number = 0;

	function EAListEntry()
	{
		super();
	}

	function FillToPct(a_pct:Number, a_origin:Number):Void
	{
		a_pct    = Math.max(0,   a_pct);
		a_pct    = Math.min(100, a_pct);
		a_origin = Math.max(0,   a_origin);
		a_origin = Math.min(100, a_origin);

		Origin  = a_origin;
		Target  = a_pct;

		if (Origin >= Target)
			return;

		Current = Origin;

		this.onEnterFrame = function()
		{
			var advanceBy:Number = ((Target - Current) / (Target - Origin));

			advanceBy *= (Math.floor((Target - Origin) / 25 + 0.99) * 0.6);

			Current = Current + advanceBy;
			if (Current > Target - 0.2)
			{
				this.onEnterFrame = null;
				Current = Target;
			}

			var frame:Number = parseInt((Current * 3).toString()); // x3 b/c tweens to frame 300
			this._meter.gotoAndStop(frame);
		}
	}
}