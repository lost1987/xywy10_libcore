package ronco.ui.GIFPlayer.gif.events
{	
	import flash.events.Event;
	import ronco.ui.GIFPlayer.gif.frames.GIFFrame;
	
	public class FrameEvent extends Event	
	{
		public var frame:GIFFrame;
	
		public static const FRAME_RENDERED:String = "rendered";
		
		public function FrameEvent ( pType:String, pFrame:GIFFrame )		
		{
			super ( pType, false, false );
			
			frame = pFrame;	
		}
	}
}