// Popup
// # TODO: Fix return data. Test photo widget upload
Stixy.extend(Stixy, {
	popup: new function(){
    this.result = null;
    this.pending_content = 'Loading...'
    this.visible = false;
    
    var manageReturnKey = function(e){
      if(e.keyCode==13){ 
        this.announce('actionkey', e);
      }
    }
    var afterFrameLoaded = function(frame, fn){
      var frameTimer = setInterval(function(){
  	    // Wait for Stixy object to be loaded and the DOM ready for interaction before calling the readyCallback
        if(frame.contentWindow.Stixy && frame.contentWindow.Stixy.state && frame.contentWindow.Stixy.state.ready===true){
  	      executeFrameLoaded();
  	    }
  	  }, 100);
      var executeFrameLoaded = function(){
        Stixy.events.stopObserving(frame, 'load', executeFrameLoaded)
        clearInterval(frameTimer);
	      fn();
      }
      // Stixy.state will not be set if it's not a Stixy page. Wait for onload event to fire
      Stixy.events.observe(frame, 'load', executeFrameLoaded)
    }
    
    var pending = function(fn){
      this.initiate();
      this.showContainer();
      if(this.ready){        
        fn();
      }else{        
        afterFrameLoaded(this.populatedFrame, fn);
      }
    }
    
    function Containor(parent, className, tagName, callback){
		  var containor = document.createElement(tagName || "div");
		  (callback || new Function)(containor)
		  containor.className = className;
      (parent||document.body).appendChild(containor);
		  return containor;
		}
		
		function PopupFrame(parent, uri, readyCallback){
	    var frame = new Containor(parent, "popup", "iframe", function(frame){
		    frame.frameBorder = "0";
		  });
		  if(uri){ 
		    frame.contentWindow.location.href = uri;
  	  }
      if(readyCallback){
        afterFrameLoaded(frame, readyCallback);
      }
		  return frame;
		}
		
    this.prepare = function(frame,width,height,returnFunction){
    	this.currentFrame = frame;
			this.setSize(width,height);
		  
    	// Due to a bug in Firefox on the Mac, we have to remove any scrollbars below the popup
			this.scrollToRemove = (Stixy.platform.mac && Stixy.ua.firefox && Stixy.ua.major < 3) ? Stixy.element.$ID("board_list_scroll") : null
			if(this.scrollToRemove && !this.storedWidth){
				this.storedWidth = this.storedWidth || this.scrollToRemove.offsetWidth;
			  var new_width = this.scrollToRemove.clientWidth - (this.scrollToRemove.offsetWidth-this.scrollToRemove.clientWidth) + "px";
				this.scrollToRemove.style.overflow = "hidden";
  			this.scrollToRemove.style.width = new_width;
			}
      
			var afterReturn = function(){
				if(returnFunction) returnFunction();
				unlistenAfterReturn();
			}.b(this);
		  this.listen("return", afterReturn);
		  
		  var unlistenAfterReturn = function(){
			  this.unlisten("return", afterReturn);
			  this.unlisten("cancel", unlistenAfterReturn);
			}.b(this);
		  this.listen("cancel", unlistenAfterReturn);
		}
    
		this.setSize = function(width,height){
			var width = this.width = (width||1008);
			var height = this.height = (height||600);
			var full_size = (width===true && height===true);
			var w = Math.min(((window.innerWidth || document.body.offsetWidth)-80),width);
	    var h = Math.min(((window.innerHeight || document.body.offsetHeight)-80),height);
	    this.currentFrame.style.left = 			  full_size ? 0 : "50%";
	    this.currentFrame.style.top = 				full_size ? 0 : "50%";
			this.currentFrame.style.marginLeft =  full_size ? 0 : -(w/2) + "px";
	    this.currentFrame.style.marginTop = 	full_size ? 0 : -(h/2) + "px";
			this.currentFrame.style.width = 			full_size ? "100%" : w + "px";
	    this.currentFrame.style.height = 		  full_size ? "100%" : h + "px";
		}
    
    this.open = function(uri,width,height,returnFunction){
      pending.b(this)(function(){
  		  this.prepare(this.navigatedFrame,width,height,returnFunction);
        this.prepare(this.populatedFrame,width,height,returnFunction);
        if(this.navigatedFrame.contentWindow.Stixy)
          this.navigatedFrame.contentWindow.Stixy.state = false
        //this.populatedFrame.contentWindow.Stixy.JSON.replaceHTML({ replace: { popup_content:'' }});
		    // Show the populated frame with the progress indicator on as a default screen
        // and close it ones the navigated frame has loaded
        this.progress();
  			this.show(); 
  			var frameLoad = function(){
    	    var closed = this.currentFrame==null;
  		    this.hide();
  		    this.currentFrame = this.navigatedFrame;
  		    // Unless the populateFrame has been closed (the load has been canceled)
  		    if(!closed){
  		      this.show();
  		    }
  		  }.b(this);
	      this.navigatedFrame.contentWindow.location = uri + ((uri.search(/\?/) > -1) ? "&" : "?") + "popupWidth=" + this.width + "&popupHeight=" + this.height;
        afterFrameLoaded(this.navigatedFrame, frameLoad);
  		}.b(this,uri,width,height,returnFunction));
		  return this;
		}
		
		this.fetchAndPopulate = function(uri,width,height,returnFunction){
		  pending.b(this)(function(){
		    this.prepare(this.populatedFrame,width,height,returnFunction);
        this.populatedFrame.contentWindow.Stixy.server.json(null, uri);
        this.show();
  		}.b(this,uri,width,height,returnFunction));
		  return this;
	  }
		
		this.populate = function(json,width,height,returnFunction){
		  pending.b(this)(function(){
  		  this.prepare(this.populatedFrame,width,height,returnFunction);
        this.populatedFrame.contentWindow.Stixy.JSON.replaceHTML({ replace: {pending_content:this.pending_content} });
  		  this.populatedFrame.contentWindow.Stixy.JSON.replaceHTML(json);
  			this.populatedFrame.contentWindow.Stixy.JSON.executeScript(json);
  		  this.show();
		  }.b(this,json,width,height,returnFunction));
		  return this;
		}
		
		this.openExternal = function(uri,width,height,returnFunction){
		  var replace = <%= { :popup_buttons => render(:partial => 'shared/popup/close_button') }.to_json %>;
		  replace.popup_content = '<iframe src="'+uri+'" frameborder="0" class="popup-external-frame"></iframe>';
		  this.populate({replace:replace},width,height,returnFunction)
		}
		
		this.initiate = function(){
      if(this.ready) return;
	    this.registerdFrame = Stixy.element.$ID("popup_frame");
		  this.registerdContainer = Stixy.element.$ID("popup_container");
			this.container = this.registerdContainer || new Containor(document.body, "popup-container");
	    this.background = new Containor(this.container, "popup-background");
	    this.navigatedFrame = this.registerdFrame || new PopupFrame(this.container);
      this.populatedFrame = new PopupFrame(this.container, Stixy.path('/public/popup_layout/'), function(){
  		  this.ready = true;
		  }.b(this));
		  this.register();
		}
		
		// Register the popup if the iframe is rendered on the page on the server side.
		// Used for the render_as_popup method
		this.register = function(){
		  if(this.registerdFrame && this.registerdContainer){
  	  	this.prepare(this.registerdFrame);
  	  	this.show();
  		}
		}
		
		this.showContainer = function(){
		  if(this.container.style.visibility == "visible") return
		  Stixy.element.setOpacity(this.background,0)
		  this.container.style.visibility = "visible";
		  new Stixy.effects.Appear(this.background, 0.1, 0.3);
    }
		
		this.hideContainer = function(){
		  new Stixy.effects.Disappear(this.background,0.1,0,function(){
  		  this.container.style.visibility = "hidden";
		  }.b(this));
    }
		
		this.show = function(){
      if(!this.container || !this.currentFrame) { return false }
      this.showContainer();
      this.currentFrame.style.display = "block";
      this.visible = true;
			Stixy.events.observe(this.currentFrame.contentWindow.document,"keyup", manageReturnKey.b(this));
      this.announce('show', this.currentFrame.contentWindow)
		}
		
		this.hide = function(){
			if(!this.container || !this.currentFrame) { return false }
		  this.width = null;
			this.height = null;
			this.progress(false);
			if(this.currentFrame.contentWindow.Stixy && this.currentFrame.contentWindow.Stixy.element){
			  var popup_content = this.currentFrame.contentWindow.Stixy.element.$ID('popup_conten');
  			if(popup_content){
  			  this.currentFrame.contentWindow.Stixy.html.replace(popup_content, '');
  			}
  			Stixy.events.stopObserving(this.currentFrame.contentWindow.document,"keyup", manageReturnKey.b(this));
			}
      this.currentFrame.style.display = "none";
      this.currentFrame = null;
			return true;
		}
		
		this.done = function(){
  		if(this.close()){
  		  this.announce("return");
  		}
		}
		
    this.close = function(){
		  this.hideContainer();
			if(this.scrollToRemove){
				this.scrollToRemove.style.overflow = "auto";
				this.scrollToRemove.style.width = this.storedWidth + "px";
				this.scrollToRemove = null;
				this.storedWidth = null;
			}
			if(this.hide()){
		    this.visible = false;
  			this.announce("close");
  			return true;
	    }
    }
    
    this.cancel = function(){
      this.close();
	    this.announce("cancel");
    }
    
    this.progress = function(state){
      var show = (state !==false) ? true : false;
      this.progressContainer = this.currentFrame.contentWindow.Stixy.element.$ID("popup_load_progress");
      if(this.progressContainer){
        this.progressContainer.style.display = show ? "block" : "none";
      }
		}
		    
		// Only pre initiate a popup if none exist
		if(!window.frameElement){
		  Stixy.listen("ready", this.initiate.b(this));
		}		
    
		return this;
	}  
});

