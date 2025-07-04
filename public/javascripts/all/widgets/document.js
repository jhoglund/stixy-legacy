Stixy.widgets.Document = function(element_id,attributes){
	this.constructor = Stixy.widgets.Document;
	this.value = element_id;
	this.attributes = attributes || {};
	this.type = 3;
	this.upload = new Stixy.widgets.Document.Upload;
	this.upload.widget = this;
	this.activate = function(){
  	Stixy.widgets.Base.call(this)
		this.text = null;
		this.resize = null;
		this.initialize("document", element_id, this.attributes);
		this.icon = Stixy.element.$CN("document-icon", Stixy.element.$CN("base",this.element)[0])[0];
		this.background = Stixy.element.$CN("base",this.element)[0];
		this.documentID = this.extract();
    this.documentName = this.icon.getAttribute("title");
		this.documentName = (this.documentName=="Add a document") ? null : this.documentName;
		this.documentType = null;
    var inline_upload_button = Stixy.element.$CN("w-d-upload", this.element)[0];
		this.inlineUpload = function(){ this.upload.open() }
		if(inline_upload_button) Stixy.events.observe(inline_upload_button,"mouseup",this.inlineUpload.b(this));
		this.active = true;
	}
	this.activate();
}
Stixy.widgets.Document.prototype = new Stixy.widgets.Base;

Stixy.widgets.Document.prototype.removeWidgetUploadButton = function(){
	var upload_button = Stixy.element.$CN("w-d-upload", this.element)[0]
  if(upload_button){
		Stixy.events.stopObserving(upload_button,"mouseup",this.inlineUpload)
		upload_button.style.display="none";
	}
}
Stixy.widgets.Document.prototype.addAfterUpload = function(result){
	var result_set = result.getElementsByTagName("i");
	if(result_set.length > 0){
		this.newDocument = true;
		for(var i=0; i<result_set.length; i++){
			var id = Stixy.XML.removeCDATASection(result_set[i].getAttribute("id"));
			this[id] = Stixy.XML.removeCDATASection(result_set[i].firstChild.nodeValue);
		}
		this.updateSource();
		this.documentSave();
		var updateSourceEvent = function(){
			this.unlisten("aftersave", updateSourceEvent);
			this.updateSource();
		}.b(this);
		this.listen("aftersave", updateSourceEvent)
  }	
}
Stixy.widgets.Document.Upload = function(){};
Stixy.widgets.Document.Upload.prototype = new Stixy.features.Upload;
Stixy.widgets.Document.Upload.prototype.settings = {
	upload_backend: "http://upload.stixy.com/widgets/documents",
	load_metadata_backend: "/widgets/document/metadata/",
	allowed_filetypes: "*.*",
	allowed_filesize: "50000",
	filetype_description: "*.* (all formats)",
	widget_offset: [20,30],
	fallback: {
	  content: function(params){
      var json = {
        replace: <%= { 
          :popup_content => render( :partial => "/widgets/document/upload.html.erb"),
          :popup_buttons => render( :partial => "/widgets/document/upload_buttons.html.erb")
          }.to_json %>
      }
      json.replace.popup_content = json.replace.popup_content.replace(/(.* name="board_id" value=")0(".*)/im,"$1"+Stixy.board.getID()+"$2")
      Stixy.popup.pending_content = this.pending_content;
      return json;
    },
    initiate: function(popupWindow){
      popupWindow.loadDocument = function(){
      	Stixy.element.addClassName(popupWindow.document.body, "show-pending");
      	popupWindow.document.forms[0].submit()
      }
   	},
	  pending_content: "Uploading document...",
		upload_backend: "/widgets/document/upload",
		width: 400,
		height: 210
	}
}
Stixy.listen("ready", function(){
  if(Stixy.ENV == 'development'){
    Stixy.widgets.Document.Upload.prototype.settings.upload_backend = Stixy.widgets.Document.Upload.prototype.settings.upload_backend.replace(/upload\.stixy\.com/, "localhost.com:81");
  }
})
Stixy.extend(Stixy.widgets.Document.Upload.prototype, new Stixy.widgets.UploadCommon);

Stixy.widgets.Document.Upload.prototype.registred = function(file){
	this.widget.removeWidgetUploadButton();
	this.insertStatusPanel(file);
}

Stixy.widgets.Document.Upload.prototype.progress = function(obj, bytesLoaded, bytesTotal, loadedPercent){
	this.widget.progressBar.style.height = loadedPercent + "%";
	this.widget.progressNumber.innerHTML = Math.round(loadedPercent) + "%";
	this.widget.statusSizeLoaded.innerHTML = this.formatedFileSize(bytesLoaded);
}

Stixy.widgets.Document.prototype.updateSource = function(attr){
	Stixy.element.toggleDisplay(this.statusPanel, false);
	var inline_namefield = Stixy.element.$CN("w-d-file-link", this.element)[0];
	var str = "<a href='/widgets/document/file/"+this.documentName+"?board_id="+Stixy.board.id+"&document_id="+this.documentID
	if(this.number>0){
		str += "&widget_id="
		str += this.number
	}
	if(this.uploadID){
		str += "&upload_id="
		str += this.uploadID
	}
  inline_namefield.innerHTML = str+"'>"+this.documentName+"</a>"
  inline_namefield.style.display = "block"
	this.icon.className = "document-icon document-icon-" +this.documentType;
  this.announce("updated");
}

Stixy.widgets.Document.Upload.prototype.insertStatusPanel = function(file){
	Stixy.element.toggleDisplay(this.widget.errorPanel, false);
	var panel = Stixy.element.$CN("status-pane",this.widget.element)[0];
	if(!panel){
		panel = document.createElement("div");
		panel.className = "status-pane";
		panel.innerHTML = "<div class='status-canvas'>" +
		"	<div class='status-content'>" +
		"		<div class='status-file-size'>Size <span class='status-file-size-loaded'>0 KB</span> of  <span class='status-file-size-total'>? KB</span></div>" +
		"		<div class='status-file-name-text'>--</div>" +
		"	</div>" +
		"	<div class='progress-canvas'>" +
		"		<div class='progress-bar'></div>" +
		"		<div class='progress-number'>0%</div>" +
		"	</div>" +
		"</div>"
		this.widget.element.appendChild(panel);
	}
	this.widget.statusPanel = panel
	this.initStatusPanel(file);
}

Stixy.widgets.Document.Upload.prototype.initStatusPanel = function(file){
	var children = this.widget.statusPanel.getElementsByTagName("*");
	this.widget.statusSizeLoaded 	= children[3];
	this.widget.statusSizeTotal 	= children[4];
	this.widget.statusFileName 		= children[5];
	this.widget.progressBar 			= children[7];
	this.widget.progressNumber 		= children[8];
	this.widget.statusSizeTotal.innerHTML = this.formatedFileSize(file.size);
	this.widget.statusFileName.innerHTML = file.name;
	Stixy.element.toggleDisplay(this.widget.statusPanel, true);
}


Stixy.widgets.Document.Upload.prototype.insertErrorMessage = function(title, message){
	var panel = Stixy.element.$CN("error-pane",this.widget.element)[0];
	if(!panel){
		panel = document.createElement("div");
		panel.className = "error-pane";
		panel.innerHTML = "<div class='error-bg'></div><div class='error-content'><strong>" + title + "</strong>" + "<div>" + message + "</div><div>";
		this.widget.element.appendChild(panel);
	}
	this.widget.errorPanel = panel;
	Stixy.element.toggleDisplay(panel, true);
}

Stixy.widgets.Document.Upload.prototype.error = function(code, file, msg){
	this.widget.removeWidgetUploadButton();
	Stixy.element.toggleDisplay(this.widget.statusPanel, false);
	switch(Number(code)){
		case -10 : 	this.insertErrorMessage("We're sorry!", "An error occured while the document was uploaded to Stixy.<br> &lt;error-code&gt;<br>&nbsp;" + msg + "<br>&lt;/error-code&gt;"); break;
		case -20 : 	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the document to Stixy"); break;
		case -30 : 	this.insertErrorMessage("We're sorry!", "There is an error in the file and it can not be uploaded to Stixy"); break;
		case -40 : 	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the document to Stixy"); break;
		case -50 : 	this.insertErrorMessage("\"" + file.name + " \" is to big!",  "The size is <b>" + this.formatedFileSize(file.size) + "</b>. Our maximum allowed file size for documtns is <b>50 MB</b>."); break;
		default  :	this.insertErrorMessage("We're sorry!", "There was an unspeciefied error while uploading the document to Stixy"); break;
	} 
}

Stixy.widgets.Document.prototype.extract = function(name){
  //if(this.icon.src.match(/.*?placeholder/)) return 0;
  //var match = (name) ? this.icon.src.match(new RegExp("[\&||\?]"+name+"=(\\d*)")) : this.icon.src.match(/\/(\d*)\?/);
	//return (match) ? parseInt(match[1]) : 0;
}
Stixy.widgets.Document.prototype.documentSave = function(){
  this.save(function(){
    return {document:{document_id:this.documentID}};
  }.b(this)());
}

// OPTIONBAR

try{
	Stixy.widgets.Optionbar.frame.listen("ready",function(){
		var optionbar = Stixy.widgets.Document.prototype.loadOptionbar("wopt-document");
  	var upload = optionbar.register(Stixy.element.$CN("w-d-upload", optionbar.panel));
	  upload.command = function(){
		  this.widget.upload.open.b(this.widget.upload)(true);
		}.b(upload);
	  upload.update = function(){
	    var namefield = Stixy.element.$CN("w-d-document-name", optionbar.panel)[0];
	    if(this.widget.documentName){
				this.sources[1].style.display = "inline";
	      this.sources[0].style.display = "none";
	      Stixy.element.removeClassName(namefield,"ghosted");
	      namefield.innerHTML = this.widget.documentName;
	    }else{
	      this.sources[1].style.display = "none";
	      this.sources[0].style.display = "inline";
	      Stixy.element.addClassName(namefield,"ghosted");
	      namefield.innerHTML = "(no document added)";
	    }
	  }.b(upload);
	  var updateStates = function(){ this.update() }.b(upload)
	  upload.activate = function(){
	    this.widget.listen("updated", updateStates);
	  }.b(upload);
	  upload.deactivate = function(){
	    this.widget.unlisten("updated", updateStates);
	  }.b(upload);
	});
}catch(e){new StixyError(e)}