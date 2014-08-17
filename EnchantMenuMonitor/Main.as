/**
 * ...
 * @author egocarib
 */

class Main 
{	
	public static var EnchantingAwakenedMenuMonitor: MenuBladeMonitor;
	
	public static function main(swfRoot:MovieClip):Void 
	{	
		var craftMenu:MovieClip = swfRoot._parent.Menu;
		EnchantingAwakenedMenuMonitor = new MenuBladeMonitor(craftMenu);
	}
	
	public function Main()
	{
	}
}