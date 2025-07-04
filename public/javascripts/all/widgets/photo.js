Stixy.widgets.Photo = function(element_id,attributes){
	this.constructor = Stixy.widgets.Photo;
	this.value = element_id;
	this.attributes = attributes || {};
  this.type = 2;
	this.upload = new Stixy.widgets.Photo.Upload;
	this.upload.widget = this;
	this.activate = function(){
		Stixy.widgets.Base.call(this)
		this.text = null;
		this.initialize("photo", element_id, attributes);
		this.photoFrame = Stixy.element.$CN("frame",this.element)[0];
		this.file = Stixy.element.$CN("base",this.element)[0].getElementsByTagName("img").item(0);
		this.background = Stixy.element.$CN("base",this.element)[0];
		this.photoID = this.attributes.id||0;
		this.angel = this.attributes.rotation||0;
		this.filter = this.attributes.filter||0;
		this.photoWidth = this.attributes.width || this.photoFrame.scrollWidth;
		this.photoHeight = this.attributes.height || this.photoFrame.scrollHeight;
		this.publicOriginalURI = this.attributes.publicOriginalURI||"";
		this.fileName = this.file.getAttribute("alt");
		this.fileName = (this.fileName=="Add a photo") ? null : this.fileName;
		var inline_upload_button = Stixy.element.$CN("w-p-upload", this.element)[0]
		this.inlineUpload = function(){ this.upload.open() }
		if(inline_upload_button) Stixy.events.observe(inline_upload_button,"mouseup", this.inlineUpload.b(this))
		this.listen("afterrotate",function(){
		  this.save({width:this.background.clientWidth,height:this.background.clientHeight});
		}.b(this));
		this.resize.proportional = true;
		this.resize.listen("afterresize",function(){
			this.initSize();
			this.setPhotoSize();
		  if(!this.photoID) return;
			this.updateSource({cancelBlank:true});
		}.b(this));
		this.active = true;
	}
	this.activate();
	this.listen("afterclone", function(){
		this.upload.removePanels();
	}.b(this))
}
Stixy.widgets.Photo.prototype = new Stixy.widgets.Base;
Stixy.widgets.Photo.prototype.initSize = function(){
	this.padding = ((document.defaultView) ? parseInt(document.defaultView.getComputedStyle(this.photoFrame,null).getPropertyValue("margin-left"))*2 : parseInt(this.photoFrame.style.margin)*2);
	this.widgetHeight = (this.background.clientHeight - this.padding);
	this.widgetWidth = (this.background.clientWidth - this.padding);
	this.baseSize = (this.widgetHeight-this.widgetWidth)/2 + this.widgetWidth;
}
Stixy.widgets.Photo.prototype.setWidgetSize = function(){
	this.widgetHeight = ((this.angel==0||this.angel==180||this.angel==360) ? this.photoHeight : this.photoWidth)  + this.padding;
	this.widgetWidth  = ((this.angel==0||this.angel==180||this.angel==360) ? this.photoWidth  : this.photoHeight) + this.padding;
}
Stixy.widgets.Photo.prototype.setPhotoSize = function(){
	this.photoHeight = ((this.angel==0||this.angel==180||this.angel==360) ? this.photoFrame.scrollHeight : this.photoFrame.scrollWidth)  ;
	this.photoWidth  = ((this.angel==0||this.angel==180||this.angel==360) ? this.photoFrame.scrollWidth  : this.photoFrame.scrollHeight) ;
}
Stixy.widgets.Photo.prototype.removeWidgetUploadButton = function(){
	var upload_button = Stixy.element.$CN("w-p-upload", this.element)[0]
	var upload_pane = Stixy.element.$CN("upload-pane", this.element)[0]
	if(upload_button){ Stixy.events.stopObserving(upload_button,"mouseup",this.inlineUpload) }
	if(upload_pane){ upload_pane.style.display="none" }
}

Stixy.widgets.Photo.prototype.addAfterUpload = function(result){
	Stixy.element.toggleDisplay(this.statusPanel, false);
	var result_set = result.getElementsByTagName("i");
	if(result_set.length > 0){
		this.newPhoto = true;
		for(var i=0; i<result_set.length; i++){
			var id = Stixy.XML.removeCDATASection(result_set[i].getAttribute("id"));
			this[id] = Stixy.XML.removeCDATASection(result_set[i].firstChild.nodeValue);
		}
		this.initSize();
		this.photoWidth  = Number(this.photoWidth);
		this.photoHeight = Number(this.photoHeight);
		this.setWidgetSize();
		this.resize.updateAspectRatio(this.widgetWidth, this.widgetHeight);
		this.updateSource({uri:this.uri});
  	this.resetUploadID = function(){
			this.uploadID = null;
			this.unlisten("aftersave", this.resetUploadID)
		}.b(this)
		this.listen("aftersave", this.resetUploadID)
	}else{
		this.upload.error();
	}
}

Stixy.widgets.Photo.Upload = function(){};
Stixy.widgets.Photo.Upload.prototype = new Stixy.features.Upload;
Stixy.widgets.Photo.Upload.prototype.settings = {
  upload_backend: "http://<%= UPLOAD_SERVER %>/widgets/photos",
	load_metadata_backend: "/widgets/photo/metadata/",
	allowed_filetypes: "*.gif; *.jpg; *.jpeg; *.png; *.GIF; *.JPG; *.JPEG; *.PNG;",
	allowed_filesize: "4000",
	filetype_description: "*.gif, *.jpg, *.png",
	fallback: {
    content: function(params){
      var json = {
        replace: <%= { 
          :popup_content => render( :partial => "/widgets/photo/upload.html.erb"),
          :popup_buttons => render( :partial => "/widgets/photo/upload_buttons.html.erb")
          }.to_json %>
      }
      json.replace.popup_content = json.replace.popup_content.replace(/(.* name="board_id" value=")0(".*)/im,"$1"+Stixy.board.getID()+"$2")
      Stixy.popup.pending_content = this.pending_content;
      var params = params.replace(/^\?/,"").split("&");
      // Replace params for popup
      for(var i=0; i<params.length; i++){
        var param = params[i].split("=");
        var pattern = ('(.* value=").*?(")(?= name="' + param[0] + '")(.*)').replace(/\[|\]/img,'.')
        json.replace.popup_content = json.replace.popup_content.replace(new RegExp(pattern),"$1" + param[1] +"$2$3")
      }
      return json;
     },
     initiate: function(popupWindow){
      popupWindow.loadPhoto = function(){
      	Stixy.element.addClassName(popupWindow.document.body, "show-pending");
      	popupWindow.document.forms[0].submit()
      }
   	},
    pending_content: "Uploading photo...",
		upload_backend: "/widgets/photo/upload",
  	width: 400,
		height: 230
	}
}


Stixy.extend(Stixy.widgets.Photo.Upload.prototype, new Stixy.widgets.UploadCommon);

// Return extra params to flash
Stixy.widgets.Photo.Upload.prototype.params = function(){
	return this.widget.generateConditionParams();
}

Stixy.widgets.Photo.Upload.prototype.registred = function(file){
	this.widget.removeWidgetUploadButton();
	this.insertStatusPanel(file);
}

Stixy.widgets.Photo.Upload.prototype.progress = function(file, bytesLoaded, bytesTotal, loadedPercent){
	this.widget.progressBar.style.width = loadedPercent + "%";
	this.widget.progressNumber.innerHTML = Math.round(loadedPercent) + "%";
	this.widget.statusSizeLoaded.innerHTML = this.formatedFileSize(bytesLoaded);
}

Stixy.widgets.Photo.Upload.prototype.insertStatusPanel = function(file){
	Stixy.element.toggleDisplay(this.widget.errorPanel, false);
	var panel = Stixy.element.$CN("status-pane",this.widget.photoFrame)[0];
	if(!panel){
		panel = document.createElement("div");
		panel.className = "status-pane";
		panel.innerHTML = "<div class='status-canvas'>" +
		"	<div class='status-bg'></div>" +
		"	<div class='status-content'>" +
		"		<div class='status-file-name'>File Name <span class='status-file-name-text'></span></div>" +
		"		<div class='status-file-size'>Size <span class='status-file-size-loaded'>0 KB</span> of  <span class='status-file-size-total'>? KB</span></div>" +
		"	</div>" +
		"	<div class='progress-canvas'>" +
		"		<div class='progress-bar'></div>" +
		"		<div class='progress-number'>0%</div>" +
		"	</div>" +
		"</div>"
		this.widget.photoFrame.appendChild(panel);
	}
	this.widget.statusPanel = panel;
	this.initStatusPanel(file);
}

Stixy.widgets.Photo.Upload.prototype.initStatusPanel = function(file){
	var children = this.widget.statusPanel.getElementsByTagName("*");
	this.widget.statusContent 		= children[2];
	this.widget.statusFileName 		= children[4];
	this.widget.statusSizeLoaded 	= children[6];
	this.widget.statusSizeTotal 	= children[7];
	this.widget.progressBar 			= children[9];
	this.widget.progressNumber 		= children[10];
	this.widget.statusSizeTotal.innerHTML = this.formatedFileSize(file.size);
	this.widget.statusFileName.innerHTML = file.name;
	Stixy.element.toggleDisplay(this.widget.statusPanel, true);
}


Stixy.widgets.Photo.Upload.prototype.insertErrorMessage = function(title, message){
	var panel = Stixy.element.$CN("error-pane",this.widget.photoFrame)[0];
	if(!panel){
		panel = document.createElement("div");
		panel.className = "error-pane";
		panel.innerHTML = "<div class='error-bg'></div><div class='error-content'><strong>" + title + "</strong>" + "<div>" + message + "</div><div>";
		this.widget.photoFrame.appendChild(panel);
	}
	this.widget.errorPanel = panel;
	Stixy.element.toggleDisplay(panel, true);
}

Stixy.widgets.Photo.Upload.prototype.error = function(code, file, msg){
	this.widget.removeWidgetUploadButton();
	Stixy.element.toggleDisplay(this.widget.statusPanel, false);
	switch(Number(code)){
		case -10 : 	this.insertErrorMessage("We're sorry!", "An error occured while the photo was uploaded to Stixy.<br> &lt;error-code&gt;<br>&nbsp;" + msg + "<br>&lt;/error-code&gt;"); break;
		case -20 : 	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the photo to Stixy"); break;
		case -30 : 	this.insertErrorMessage("We're sorry!", "There is an error in the file and it can not be uploaded to Stixy"); break;
		case -40 : 	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the photo to Stixy"); break;
		case -50 : 	this.insertErrorMessage("\"" + file.name + " \" is to big!",  "The size is <b>" + this.formatedFileSize(file.size) + "</b>. Our maximum allowed file size for photos is <b>4 MB</b>. If you need to add larger files, please upload it as a \"Document\", or resize the photo before uploading it."); break;
		default  :	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the photo to Stixy"); break;
	} 
}

Stixy.widgets.Photo.prototype.generateQuery = function(str){
  return "?board_id="+Stixy.board.id+"&photo_id="+this.photoID+(str ? ("&"+str) : "");
}

Stixy.widgets.Photo.prototype.generateUrl = function(str){
	return "/widgets/photo/thumb/"+this.fileName+this.generateQuery(str);
}

Stixy.widgets.Photo.prototype.generateOriginalUrl = function(){
	return "/widgets/photo/photo/"+this.fileName+this.generateQuery(this.generateParams());
}

Stixy.widgets.Photo.prototype.generateConditionParams = function(attr){
	var attr = attr||{}
  if(attr.filter>=0) this.filter = attr.filter;
	var str = "conditions[filter]=" + this.filter +      // Filter ID
            "&conditions[rotation]=" + this.angel +    // Rotation angel
            "&conditions[width]=" + this.photoWidth +  // Photo width
            "&conditions[height]=" + this.photoHeight  // Photo height
	return str;
}

Stixy.widgets.Photo.prototype.generateParams = function(attr){
	var str = this.generateConditionParams(attr);
  if(this.uploadID){
		str += "&upload_id="
		str += this.uploadID
	}
	if(this.number>0){
		str += "&widget_id="
		str += this.number
	}
	return str;
}

Stixy.widgets.Photo.prototype.updateSource = function(attr){
	var attr = attr||{}
	var str = this.generateParams(attr);
	this.photoSave(str);
	if(attr.cancelBlank!==true) this.file.setAttribute("src","/images/main_template/transparent.gif");
	this.file.setAttribute("alt",this.fileName);
	setTimeout(function(){
	  this.file.setAttribute("src", attr.uri || this.generateUrl(str));
	  this.announce("updated");
  }.b(this),300);
}
Stixy.widgets.Photo.prototype.extract = function(name){
  if(this.file.src.match(/.*?placeholder/)) return 0;
  var match = this.file.src.match(new RegExp("[\&||\?]"+name+"=(\\d*)"));
	return (match) ? parseInt(match[1]) : 0;
}
Stixy.widgets.Photo.prototype.photoSave = function(){
	this.save(function(){
		return {photo:{photo_id:this.photoID}};
  }.b(this)());
}
Stixy.widgets.Photo.prototype.autoUpload = false;

// OPTIONBAR

try{
	Stixy.widgets.Optionbar.frame.listen("ready",function(){
		var optionbar = Stixy.widgets.Photo.prototype.loadOptionbar("wopt-photo");
		var upload = optionbar.register(Stixy.element.$CN("w-p-upload", optionbar.panel));
	  upload.command = function(){
			this.widget.upload.open.b(this.widget.upload)(true);
		}.b(upload);
	  upload.update = function(){
			var namefield = Stixy.element.$CN("w-p-image-name", optionbar.panel)[0];
	    if(this.widget.fileName){
	      this.sources[1].style.display = "inline";
	      this.sources[0].style.display = "none";
	      Stixy.element.removeClassName(namefield,"ghosted");
	      namefield.innerHTML = this.widget.fileName;
	    }else{
	      this.sources[1].style.display = "none";
	      this.sources[0].style.display = "inline";
	      Stixy.element.addClassName(namefield,"ghosted");
	      namefield.innerHTML = "(no image added)";
	    }
	  }.b(upload);
	  var updateStates = function(){ this.update() }.b(upload)
	  upload.activate = function(){
	    this.widget.listen("updated", updateStates);
	  }.b(upload);
	  upload.deactivate = function(){
	    this.widget.unlisten("updated", updateStates);
	  }.b(upload);
	
		var get_original = optionbar.register(Stixy.element.$CN("w-p-get-original", optionbar.panel)[0]);
	  get_original.command = function(){
			window.location.href = this.widget.generateOriginalUrl();
		}.b(get_original);
	  get_original.update = function(){
	    if(this.widget.fileName){
	      this.source.style.display = "inline";
	    }else{
	      this.source.style.display = "none";
	    }
	  }.b(get_original);
	  var originalUpdateStates = function(){ this.update() }.b(get_original)
	  get_original.activate = function(){
	    this.widget.listen("updated", originalUpdateStates);
	  }.b(get_original);
	  get_original.deactivate = function(){
	    this.widget.unlisten("updated", originalUpdateStates);
	  }.b(get_original);
	
	
	  var filter = optionbar.register(Stixy.element.$CN("w-p-theme-effects", optionbar.panel));
	  var filterValues = ["w-p-theme-noeffect","w-p-theme-gray","w-p-theme-sepia"];
	  filter.command = function(){
	    var filterIndex = function(){ for(var i=0; i<filterValues.length; i++) if(filterValues[i]==this.source.id) return i }.b(this)();
	    this.widget.updateSource({filter: filterIndex}) 
	  }.b(filter);
	  filter.update = function(){
			for(var i=0; i<this.sources.length; i++){
				var source = this.sources[i];
				if(this.widget.fileName){
					Stixy.element.addClassName(source, "activated");
					if(source.id==filterValues[this.widget.filter]) this.state(source);
				}else{
					Stixy.element.removeClassName(source, "activated");
					this.state();
				}
			}
	  }.b(filter)
	  var updateFilter = function(){ this.update() }.b(filter)
	  filter.activate = function(){
	    this.widget.listen("updated", updateFilter);
	  }.b(filter);
	  filter.deactivate = function(){
	    this.widget.unlisten("updated", updateFilter);
	  }.b(filter);
	
		var rotate = optionbar.register(Stixy.element.$CN("w-p-theme-rotation", optionbar.panel))
	  rotate.command = function(){
	    var rightway = (function(a){ return (a==0||a==180||a==360) })(this.widget.angel)
			this.widget.angel = (function(tool){
				for(var i=0; i<tool.sources.length; i++){
					if(tool.sources[i]==tool.source) return i*90
				}
			})(this)
			var sideway = (function(n){ return (n==90||n==270) })(this.widget.angel)
			this.widget.updateSource({rotate:this.widget.angel});
			if(rightway&&sideway||!rightway&&!sideway) this.widget.rotate();
		}
		rotate.update = function(){
			this.state(this.sources[this.widget.angel/90]||this.sources[0])
		}
	  
		var frame = optionbar.register(Stixy.element.$CN("w-p-theme-border", optionbar.panel))
	  //var add = function(){ return parseInt(this.widget.photoFrame.style.marginLeft)==0 }.b(optionbar);
	  frame.command = function(){
			var margin = this.widget.photoFrame.style.marginLeft;
			var add = (function(){ return parseInt(margin)==0 })();
			var padding = (add) ? "10px":"0px";
	    this.widget.element.style.width = parseInt(this.widget.element.style.width) + ((add) ? 20:-20) +"px";
	    this.widget.element.style.height = parseInt(this.widget.element.style.height) + ((add) ? 20:-20) +"px";
	    this.widget.element.style.top = parseInt(this.widget.element.style.top) + ((add) ? -10:10) +"px";
	    this.widget.element.style.left = parseInt(this.widget.element.style.left) + ((add) ? -10:10) +"px";
			this.widget.photoFrame.style.margin = padding;
			this.widget.photoFrame.style.paddingTop = padding;
			this.widget.photoFrame.style.paddingBottom = padding;
			this.widget.photoFrame.style.top = "-" + padding;
			this.widget.photoFrame.style.bottom = padding;
			this.widget.resize.announce("afterresize")
			this.widget.updateSource();
	  }
	  frame.update = function(){
			for(var i=0; i<this.sources.length; i++){
				if(parseInt(this.widget.photoFrame.style.marginLeft)==0) {
					this.state(this.sources[i]);
					return;
				}
			}
			this.state(this.sources[1]);
		}
	  frame.save = function(){
	    return {
	      style: {margin:{value:parseInt(this.widget.photoFrame.style.marginLeft), name:"image-margin"}},
				width:this.widget.background.clientWidth,
				height:this.widget.background.clientHeight,
      	top:parseInt(this.widget.element.style.top),
				left:parseInt(this.widget.element.style.left)
	    }
	  }
	});
}catch(e){new StixyError(e)}