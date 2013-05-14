package ronco.base
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	//! 数据下载类，单线下载
	public class DataLoader
	{
		public static var singleton:DataLoader = new DataLoader();
		
		//! "id", "url", "func", "loader", "dataFormat", "isswf", "swfname", "isloading", "initlevel"
		//! Boolean onLoad(id:int, url:String, isOK:Boolean, loader:URLLoader)
		//! Boolean onLoad(id:int, url:String, isOK:Boolean, loader:Loader)
		public var lstRes:Vector.<Object> = new Vector.<Object>();
//		
//		//! "id", "name", "url", "loader", "func"
//		//! void onLoad(id:int, url:String, isOK:Boolean, loader:URLLoader)
//		public var lstSwf:Vector.<Object> = new Vector.<Object>();
		
		/**
		 * 下载完的swf，可以通过名字查找
		 **/ 
		public var dictSwf:Dictionary = new Dictionary;
		
		public var isBegin:Boolean = false;
		
		//! void onBegin()
		public var funcBegin:Function;
		//! void onEnd()
		public var funcEnd:Function;
		//! void onRefurbish(per:Number)
		public var funcRefurbish:Function;
		
		//public var listener:ListenerModuleMgr;
		public var maxNums:int = 0;
		
		/**
		 * 初始化级别，当前加载完的项的级别等于该级别时，执行下载成功函数，执行完后，该级别++
		 **/ 
		public var curInitLevel:int = 0;
		
		/**
		 * 同时下载数量
		 **/ 
		public const DOWNLOAD_THREAD_NUMS:int		=	10;
		
		public function DataLoader()
		{
		}
		
		public function addLoader(id:int, url:String, dataFormat:String, func:Function):URLLoader
		{
			var obj:Object = new Object();
			
			obj["id"] = id;
			obj["dataFormat"] = dataFormat;
			obj["url"] = url;
			obj["func"] = func;
			obj["loader"] = new URLLoader();
			obj["isswf"] = false;
			obj["isloading"] = false;
			
			lstRes.push(obj);
			
			++maxNums;
			
			return obj["loader"]; 
		}
		
		public function addSwfLoader(id:int, name:String, url:String, func:Function):Loader
		{
			var obj:Object = new Object();
			
			obj["id"] = id;
			obj["url"] = url;
			obj["func"] = func;
			obj["loader"] = new Loader();
			obj["isswf"] = true;
			obj["swfname"] = name;
			obj["isloading"] = false;
			
			lstRes.push(obj);
			
			++maxNums;
			
			return obj["loader"]; 
		}		
		
		public function start():void
		{
			if(!isBegin)
			{
				if(funcBegin != null)
					funcBegin();
				
				isBegin = true;
			}
			
			var i:int = 0;
			var len:int = lstRes.length;			
			
			if(len > 0)
			{
				var request:URLRequest;
			
				while(i < len && i < DOWNLOAD_THREAD_NUMS)
				{
					if(!lstRes[i]["isloading"])
					{
						if(lstRes[i]["isswf"])
						{
							var context:LoaderContext = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain));
							lstRes[i]["loader"].contentLoaderInfo.addEventListener(Event.COMPLETE, onDownloadComplete);
							lstRes[i]["loader"].contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);
							
							try{
								lstRes[i]["loader"].load(new URLRequest(lstRes[i]["url"]), context);
								
								lstRes[i]["isloading"] = true;
							}
							catch(err:Error) {
								lstRes[i]["isloading"] = false;
							}
						}
						else
						{
							lstRes[i]["loader"].addEventListener(Event.COMPLETE, onDownloadComplete);
							lstRes[i]["loader"].addEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);
							
							lstRes[i]["loader"].dataFormat = lstRes[i]["dataFormat"];
							
							//MainLog.singleton.output("DataLoader::start(" + lstRes[0]["url"] + ")");
							
							try{
								request = new URLRequest(lstRes[i]["url"]);
								lstRes[i]["loader"].load(request);
								
								lstRes[i]["isloading"] = true;
							}
							catch(err:Error) {
								
								lstRes[i]["isloading"] = false;
								//MainLog.singleton.output("DataLoader::start(" + lstRes[0]["url"] + ") err - " + err.errorID + " " + err.message);
							}					
						}	
					}
					
					++i;
				}
				
				if(funcRefurbish != null)
					funcRefurbish((maxNums - lstRes.length) / Number(maxNums));
			}
			else
			{
				if(funcEnd != null)
					funcEnd();
				
				isBegin = false;
			}
		}
		
		private function onDownloadFail(e:Event):void
		{
			var i:int;
			var isstart:Boolean
			var len:int = lstRes.length;
			
			for(i = 0; i < len; ++i)
			{
				if(lstRes[i]["isswf"])
				{
					if(lstRes[i]["loader"].contentLoaderInfo == e.target)
					{
						MainLog.singleton.output("DataLoader::onDownloadFail - " + lstRes[i]["url"]);
						
						lstRes[i]["loader"].contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownloadComplete);
						lstRes[i]["loader"].contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);
						
						lstRes[i]["isloading"] = false;
						
						start();
						
//						isstart = lstRes[i]["func"](lstRes[i]["id"], lstRes[i]["url"], false, lstRes[i]["loader"]);
//						
//						lstRes.splice(i, 1);
//						
//						if(isstart)
//							start();
						
						return ;						
					}
				}
				else if(lstRes[i]["loader"] == e.target)
				{
					MainLog.singleton.output("DataLoader::onDownloadFail - " + lstRes[i]["url"]);
					
					lstRes[i]["loader"].removeEventListener(Event.COMPLETE, onDownloadComplete);
					lstRes[i]["loader"].removeEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);
					
					lstRes[i]["isloading"] = false;
					
					start();					
					
//					isstart = lstRes[i]["func"](lstRes[i]["id"], lstRes[i]["url"], false, lstRes[i]["loader"]);
//					
//					lstRes.splice(i, 1);
//					
//					if(isstart)
//						start();
					
					return ;
				}
			}
		}
		
		private function onDownloadComplete(e:Event):void
		{
			var i:int;
			var isstart:Boolean
			var len:int = lstRes.length;
			
			for(i = 0; i < len; ++i)
			{
				if(lstRes[i]["isswf"])
				{
					if(lstRes[i]["loader"].contentLoaderInfo == e.target)
					{
						dictSwf[lstRes[i]["swfname"]] = lstRes[i]["loader"];
						
						isstart = lstRes[i]["func"](lstRes[i]["id"], lstRes[i]["url"], true, lstRes[i]["loader"]);
						
						lstRes[i]["loader"].contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownloadComplete);
						lstRes[i]["loader"].contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);						
						
						lstRes.splice(i, 1);
						
						if(isstart)
							start();
						
						return ;						
					}
				}
				else if(lstRes[i]["loader"] == e.target)
				{	
					isstart = lstRes[i]["func"](lstRes[i]["id"], lstRes[i]["url"], true, lstRes[i]["loader"]);
					
					lstRes[i]["loader"].removeEventListener(Event.COMPLETE, onDownloadComplete);
					lstRes[i]["loader"].removeEventListener(IOErrorEvent.IO_ERROR, onDownloadFail);					
					
					lstRes.splice(i, 1);
					
					if(isstart)
						start();
					
					return ;
				}
			}			
		}
	}
}