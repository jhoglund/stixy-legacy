import flash.net.FileReferenceList;
import flash.external.ExternalInterface;
import flash.net.FileReference;
import logger;

class FileUpload {
	private var listener:Object = new Object();
	private var imageFile;
	private var uploadableItems:Array = new Array();
	private var currentUploadingItem:FileReference = null;
	private var upload_id:String;
	private var before_start:Boolean = true;
	private var widget_id:String;
	
	public var uploadErrorCallback:String;
	public var uploadCompleteCallback:String;
	public var uploadProgressCallback:String;
	public var uploadCancelCallback:String;
	public var uploadStartCallback:String;
	public var uploadBeforeStartCallback:String;
	public var allowedFiletypes:String;
	public var fileDescription:String;
	public var allowedFilesize:String;
	public var uploadBackend:String;
	public var uploadQueueCompleteCallback:String;
	

	function FileUpload(single){
		imageFile = (single) ? FileReference(new FileReference()) : FileReferenceList(new FileReferenceList());
		var class_ref = this;
		listener.onOpen = function(file:FileReference):Void {
			if(class_ref.uploadStartCallback)
			ExternalInterface.call(class_ref.uploadStartCallback, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type, creationdate: file.creationDate, creator: file.creator});
		}
		listener.onCancel = function():Void {
			if(class_ref.uploadCancelCallback){
				ExternalInterface.call(class_ref.uploadCancelCallback);
			}
		}		
		listener.onProgress = function(file:FileReference, bytesLoaded:Number, bytesTotal:Number):Void {
			if (class_ref.uploadProgressCallback.length > 0){
				ExternalInterface.call(class_ref.uploadProgressCallback, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type}, bytesLoaded, bytesTotal, (bytesLoaded/bytesTotal)*100 );
			}
		}	
		listener.onComplete = function(file:FileReference):Void {
			if (class_ref.uploadCompleteCallback.length > 0){
				ExternalInterface.call(class_ref.uploadCompleteCallback, {id:class_ref.widget_id, tempID:class_ref.upload_id, name: file.name, size: file.size, type: file.type});
			}
			class_ref.notifyComplete();
		}		
		listener.onHTTPError = function(file:FileReference, httpError:Number):Void {
			ExternalInterface.call(class_ref.uploadErrorCallback, -10, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type}, httpError);
		}		
		listener.onIOError = function(file:FileReference):Void {
			if(!class_ref.uploadBackend.length) {
				ExternalInterface.call(class_ref.uploadErrorCallback, -20, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type}, "No backend file specified");
			} else {
				ExternalInterface.call(class_ref.uploadErrorCallback, -30, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type});
			}
		}		
		listener.onSecurityError = function(file:FileReference, errorString:String):Void {
			ExternalInterface.call(class_ref.uploadErrorCallback, -40, {id:class_ref.widget_id, name: file.name, size: file.size, type: file.type}, errorString);
		}
		if(single){
			listener.onSelect = function(item:FileReference) {
				class_ref.addItemToQue(item);
				class_ref.notifyBeforeUpload();
			}
		}else{
			listener.onSelect = function(fileRefList:FileReferenceList) {
				var list:Array = fileRefList.fileList;
				for(var i:Number = 0; i < list.length; i++) {
					class_ref.addItemToQue(list[i]);
				}
				class_ref.notifyBeforeUpload();
			}
		}
		imageFile.addListener(class_ref.listener);
	}
	// Call the uploadImage() function, opens a file browser dialog.
	public function uploadFile(event:Object, id:String):Void {
		this.widget_id = id;
		this.imageFile.browse([{description: this.fileDescription , extension: this.allowedFiletypes}]);
	}	
	// function check the size of each of the files given
	private function checkSize(item:FileReference):Boolean{
		return item.size < (this.allowedFilesize * 1000);
	}	
	// call this function when some items have been added to the uploadableItems list.
	// or you want to start another upload
	private function notifyBeforeUpload(){
		// Call BeforeStart of External interface if the first item
		if(this.uploadBeforeStartCallback.length > 0){
			var temp:Array = new Array;
			for(var i:Number=0; i<this.uploadableItems.length; i++){
				temp.push({
						  size:this.uploadableItems[i].size,
						  name:this.uploadableItems[i].name,
						  type:this.uploadableItems[i].type,
						  creator:this.uploadableItems[i].creator,
						  modificationDate:this.uploadableItems[i].modificationDate
						  })
			}
			ExternalInterface.call(this.uploadBeforeStartCallback, { files: temp });
		}
		notifyUpload();
	}
	
	private function notifyUpload(){
		// check to see if we have anything to do:
		if(this.currentUploadingItem === null && this.uploadableItems.length > 0){
			this.currentUploadingItem = FileReference(this.uploadableItems.shift());
			if(this.currentUploadingItem){
				this.upload_id = String(ExternalInterface.call("Stixy.tempID.get"));
				var session_id:String = String(ExternalInterface.call("Stixy.session.getID"));
				this.currentUploadingItem.addListener(this.listener);
				this.currentUploadingItem.upload(this.uploadBackend + "/" + this.upload_id + "?_type=" + escape(this.currentUploadingItem.type) + "&_session_id=" + session_id);
			}else{
				//trace("something went wrong with the [cast]pop from uploadableItems.");
			}
		}else{
			if(this.uploadQueueCompleteCallback.length > 0){
				ExternalInterface.call(this.uploadQueueCompleteCallback, {id:this.widget_id});
			}
		}
	}
	
	
	private function addItemToQue(item:FileReference){
		if(this.checkSize(item)) {
			this.uploadableItems.push(item);
			//this.notifyUploadItemQueued(item);
		} else {
			ExternalInterface.call(this.uploadErrorCallback, -50, {id:this.widget_id, name: item.name, size: item.size, type: item.type}, "Filesize exceeds allowed limit.");
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
	//private function notifyUploadItemQueued(file:FileReference){
		//if (this.uploadStartCallback.length > 0){
			//ExternalInterface.call(this.uploadStartCallback, {id:this.widget_id, name: file.name, size: file.size, type: file.type, creationdate: file.creationDate});
		//}
	//}
}