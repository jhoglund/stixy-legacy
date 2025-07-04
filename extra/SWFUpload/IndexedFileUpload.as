import flash.net.FileReferenceList;
import flash.net.FileReference;
import flash.external.ExternalInterface;
import logger;

class FileUpload {
	private var listener:Object = new Object();
	private var imageFile:FileReferenceList;	
	private var uploadableItems:Array = new Array();
	private var currentUploadingItem:FileReference = null;
	private var upload_id:String;
	private var before_start:Boolean = true;
	private var item_index:Number = 0;
	private var widget_id:String;
	
	public var uploadErrorCallback:String;
	public var uploadCompleteCallback:String;
	public var uploadProgressCallback:String;
	public var uploadCancelCallback:String;
	public var uploadStartCallback:String;
	public var uploadBeforeStartCallback:String;
	public var allowedFiletypes:String;
	public var allowedFilesize:String;
	public var uploadBackend:String;
	public var uploadQueueCompleteCallback:String;

	function FileUpload(){
		imageFile = new FileReferenceList();
		var class_ref = this;
		listener.onCancel = function():Void {
			if(class_ref.uploadCancelCallback){
				ExternalInterface.call(class_ref.uploadCancelCallback);
			}
		}		
		listener.onProgress = function(file:FileReference, bytesLoaded:Number, bytesTotal:Number):Void {
			if (class_ref.uploadProgressCallback.length > 0){
				ExternalInterface.call(class_ref.uploadProgressCallback, {id:class_ref.widget_id, index: class_ref.item_index, name: file.name, size: file.size, type: file.type}, bytesLoaded, bytesTotal, Math.round((bytesLoaded/bytesTotal)*100) );
			}
		}	
		listener.onComplete = function(file:FileReference):Void {
			if (class_ref.uploadCompleteCallback.length > 0){
				ExternalInterface.call(class_ref.uploadCompleteCallback, {id:class_ref.widget_id, index: class_ref.item_index++, tempID:class_ref.upload_id, name: file.name, size: file.size, type: file.type});
			}
			class_ref.notifyComplete();
		}		
		listener.onHTTPError = function(file:FileReference, httpError:Number):Void {
			ExternalInterface.call(class_ref.uploadErrorCallback, -10, httpError, {id:class_ref.widget_id, index: class_ref.item_index, name: file.name, size: file.size, type: file.type}, httpError);
		}		
		listener.onIOError = function(file:FileReference):Void {
			if(!class_ref.uploadBackend.length) {
				ExternalInterface.call(class_ref.uploadErrorCallback, -20, {id:class_ref.widget_id, index: class_ref.item_index, name: file.name, size: file.size, type: file.type}, "No backend file specified");
			} else {
				ExternalInterface.call(class_ref.uploadErrorCallback, -30, {id:class_ref.widget_id, index: class_ref.item_index, name: file.name, size: file.size, type: file.type});
			}
		}		
		listener.onSecurityError = function(file:FileReference):Void {
			ExternalInterface.call(class_ref.uploadErrorCallback, -40, {id:class_ref.widget_id, index: class_ref.item_index, name: file.name, size: file.size, type: file.type});
		}		
		listener.onSelect = function(fileRefList:FileReferenceList) {
			var list:Array = fileRefList.fileList;
			var item:FileReference;
			for(var i:Number = 0; i < list.length; i++) {
				item = list[i];
				//item.index = class_ref.item_index;
				if(class_ref.checkSize(item)) {
					class_ref.uploadableItems.push(item);
					class_ref.notifyUploadItemQueued(item);
				} else {
					ExternalInterface.call(class_ref.uploadErrorCallback, -50, {id:class_ref.widget_id, name: item.name, size: item.size, type: item.type}, "Filesize exceeds allowed limit.");
				}
			}
			class_ref.notifyUpload();
		}			
		imageFile.addListener(class_ref.listener);
	}
	// Call the uploadImage() function, opens a file browser dialog.
	public function uploadImage(event:Object, id:String):Void {
		this.widget_id = id;
		this.imageFile.browse([{description: "File upload", extension: this.allowedFiletypes}]);
	}	
	// function check the size of each of the files given
	private function checkSize(item:FileReference):Boolean{
		return item.size < (this.allowedFilesize * 1000);
	}	
	// call this function when some items have been added to the uploadableItems list.
	// or you want to start another upload
	private function notifyUpload(){
		// Call BeforeStart of External interface if the first item
		if(this.before_start == true){
			this.before_start = false;
			if (this.uploadBeforeStartCallback.length > 0){
				ExternalInterface.call(this.uploadBeforeStartCallback, {id:this.widget_id, items: this.uploadableItems });
			}
		}
		// check to see if we have anything to do:
		if(this.currentUploadingItem === null && this.uploadableItems.length > 0){
			this.currentUploadingItem = FileReference(this.uploadableItems.shift());
			if(this.currentUploadingItem){
				this.upload_id = String(ExternalInterface.call("Stixy.tempID.get"));
				var session_id:String = String(ExternalInterface.call("Stixy.session.getID"));
				this.currentUploadingItem.addListener(this.listener);
				logger.debug(this.uploadBackend);
				this.currentUploadingItem.upload(this.uploadBackend + "/" + this.upload_id + "?_session_id=" + session_id);
			}else{
				//trace("something went wrong with the [cast]pop from uploadableItems.");
			}
		}else{
			if(this.uploadQueueCompleteCallback.length > 0){
				ExternalInterface.call(this.uploadQueueCompleteCallback);
			}
		}
	}	
	// call this function where the items.listener says that the upload is complete
	private function notifyComplete(){
		delete this.currentUploadingItem;
		this.currentUploadingItem=null;
		// check for more uploads
		this.notifyUpload();
	}
	
	// call the external javascript(if set) that we have the file and it __will__ be uploaded...
	// replaces the listener.onOpen callback
	private function notifyUploadItemQueued(file:FileReference){
		if (this.uploadStartCallback.length > 0){
			ExternalInterface.call(this.uploadStartCallback, {id:this.widget_id, index: this.item_index, name: file.name, size: file.size, type: file.type, creationdate: file.creationDate});
		}
	}
}

class IndexedFileReference extends FileReference { 
	public var index:Number; 
	function IndexedFileReference(){
		
	}
}