Stixy.features.Upload = function(settings){
	this.settings = settings;
}
Stixy.features.Upload.prototype = new function(){
	this.getTarget = function(){
		return this.global.target;
	}
	this.register = function(target, callback){
		this.global.pending.push(target);
		this.target = target;
		this.registred(callback);
		return true;
	}
	this.cancelPendingAction = function(){ }
	this.open = function(type){
	  if(Stixy.flash.isCompatible(10)){
	    this.openFallback();
	  }else{
	    if(this.global.source){
  			alert("Please wait for the currently uploading of files to complete before uploading more");
  		}else if(Stixy.flash.loaded && this.global.flash_enabled && this.global.containor && this.global.containor.source && this.global.containor.source.upload){
  			this.global.source = this;
  			this.beforeOpen();
  			this.global.containor.source.upload(null, "--", this.settings, type);
  		}else{
  			this.openFallback();
  		}
	  }
	}
	this.openFallback = function(){    
    if(this.settings.fallback.content){
      if(this.settings.fallback.initiate){
        Stixy.popup.listen('show', this.settings.fallback.initiate.b(this));
      }
      if(this.settings.fallback.cancel){
        Stixy.popup.listen('cancel', this.settings.fallback.cancel.b(this));
      }
      if(this.settings.fallback.done){
        Stixy.popup.listen('done', this.settings.fallback.done.b(this));
      }
      Stixy.popup.populate(this.settings.fallback.content(this.params()),this.settings.fallback.width,this.settings.fallback.height, function(){
      	this.fallback(Stixy.popup.result)
      }.b(this));
    }else if(this.settings.fallback.upload_backend){
      Stixy.popup.open(this.settings.fallback.upload_backend+"/"+Stixy.board.getID()+"?"+this.params(),this.settings.fallback.width,this.settings.fallback.height,function(){
      	this.fallback(Stixy.popup.result)
      }.b(this))
    }
	}
	this.formatedFileSize = function(size){ 
		var kb = Math.round(size/1024);
		return ((kb>999) ? ((Math.round(kb/100)/10) + " MB") : (kb + " KB"))
	}
	this.removePanels = function(){
		if(this.widget.statusPanel){
			this.widget.statusPanel.parentNode.removeChild(this.widget.statusPanel);
			delete this.widget.statusPanel;
		}
		if(this.widget.errorPanel){
			this.widget.errorPanel.parentNode.removeChild(this.widget.errorPanel);
			delete this.widget.errorPanel;
		}
	}
	this.beforeOpen = this.beforeUpload = this.registred = this.beforeStart = this.start = this.progress = 
	this.error = this.finished = this.cancel = this.complete = this.fallback = this.params = function(){ }
	this.global = new function(){
		this.source = null;
		this.target = null;
		var okPendingAction = function(){
			this.cancelCallback();
		}
		this.okPendingAction = okPendingAction.b(this)
		this.nextTarget = function(){
			this.target = this.pending.pop();
			return this.source;
		}
		this.pending = [];
		this.object_name = "StixyUploadObject";
		this.compatible = Stixy.flash.isCompatible(8);
		this.flash_enabled = this.compatible;
		this.params = function(){
		  // Return extra params to flash from current target, if params function is defined
      return this.source.params.apply(this.source, arguments);
  	}
		this.beforeStartCallback 	=	function(){ this.source.beforeStart.apply(this.source, arguments) }
		this.beforeUploadCallback =	function(){ this.nextTarget().beforeUpload.apply(this.source, arguments) }
		this.startCallback 				=	function(){ this.source.start.apply(this.source, arguments) }
		this.progressCallback	 		=	function(){ this.source.progress.apply(this.source, arguments) }
		this.errorCallback 				=	function(){ 
			this.source.error.apply(this.source, arguments) 
			this.source = null;
		}
		this.endCallback	 				=	function(){ this.source.finished.apply(this.source, arguments) }
		this.cancelCallback	 			=	function(){
			this.source.cancel.apply(this.source, arguments);
      this.source = null;
		}
		this.completeCallback	 		=	function(){ 
			this.source.complete.apply(this.source, arguments);
      this.source = null;
		}
		this.create = function(){
			if(this.compatible){ 
				return Stixy.flash.add("/embeds/upload.swf", null, this.object_name) }
		}
		this.containor = this.create();
	}
}