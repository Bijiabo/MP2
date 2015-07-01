#下载模块文档

###新建实例

	var downloader : Downloader = Downloader()
	

###新建下载

	func download(remoteURL: String , cacheRootURL : NSURL , filename : String?) -> Int
	
filename参数主要用于指定下载文件的保存名称，若不指定如写`nil`则使用远程连接后缀来保存文件。
	
###下载状态切换方法

	func start(index : Int)
    func pause(index : Int)
    func cancel(index : Int)
    func resume(index : Int)
    
###delegte

协议：`DownloaderObserverProtocol`

方法：

	//下载完成
    func downloadCompleted(data : AnyObject)
    
    //下载出错
    func downloadErrorOccurd(data : AnyObject)
    
    //下载进度（可选）
    func refreshDownloadProgressFor(#id:Int , progress : Float)

####设定delegate

	downloader.delegate = {your Class instance}
	
