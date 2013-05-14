package ronco.base
{
	import flash.net.URLLoader;
	
	import mx.core.*;
	import mx.modules.IModuleInfo;

	public class ModuleInfo
	{
		public var mod:Module;						// 我们的模块
		//public var imod:IModuleInfo;				// flash模块
		public var file:ModuleFileInfo;			// 模块文件
		public var modType:int;					// 模块类型
		public var modid:int;						// 模块ID
		public var visibleParent:UIComponent;		// 模块的父节点
		public var x:int;							// x
		public var y:int;							// y
		public var isBeginOnReady:Boolean;			// 载入后是否调用 BeginModule			
		public var isInited:Boolean = false;
		public var modName:String;					// 模块名
		public var isBegin:Boolean = false;
		
		public var urlloader:URLLoader = new URLLoader;
		public var filename:String;
		
		public function ModuleInfo()
		{
		}
	}
}