// Server
Stixy.extend(Stixy, {
	server: {
	  delay: 30000,
	  state: 0,
		autoSave: true,
		connectionState: true,
		initStorageQue: function(){
			return {boards:{},length:0}
		},
		initQues: function(){
			return {
				storage: this.initStorageQue(),
				pending: null
			}
		},
		toggleAutoSave: function(state){
		  if(this.autoSave || state===false){
		    this.autoSave = false;
		    Stixy.element.addClassName(Stixy.ui.base, 'disable-auto-save');
		  }else if(!this.autoSave || state===true){
		    this.autoSave = true;
		    Stixy.element.removeClassName(Stixy.ui.base, 'disable-auto-save');
		  }
		},
	  start: function(){
	  	if(!this.autoSave) { return }
	  	this.stop();
			this.saveInterval = setInterval(this.update.b(this), this.delay);
			this.seconds = this.delay/1000
			this.count()
			this.saveCounter = setInterval(this.count.b(this), 1000);
	  },
		request: (function(){
		  var xmlhttp;
		  try { xmlhttp = new ActiveXObject("Msxml2.XMLHTTP"); }
		  catch (e) { try { xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); }
		  catch (e) { try { xmlhttp = new XMLHttpRequest(); }
		  catch (e) { xmlhttp = false; }}}
		  if(!xmlhttp) { return null }
		  return xmlhttp;
		})(),
		stop: function(){
			clearInterval(this.saveInterval);
			clearInterval(this.saveCounter);
		},
		count: function(){
			Stixy.element.$ID("save_counter").innerHTML = this.seconds--;
		},
		save: function(widget){
			if(!Stixy.server.canBeSaved) { return }
			this.ques = this.ques || this.initQues();
			if(this.ques.storage.length==0){
        this.start();
				this.setState(1);
			}
			var boardId = "board_" + widget.boardId;
			this.ques.storage.boards[boardId] = this.ques.storage.boards[boardId] || function(){
				this.ques.storage.length++;
				return [];
			}.b(this)();
			this.ques.storage.boards[boardId].push(widget);
		},
		removeFromQue: function(widget){			
			var boardId = "board_" + widget.boardId;
			if(this.ques && this.ques.storage && this.ques.storage.boards && this.ques.storage.boards[boardId]){
    	  for(var i=0; i<this.ques.storage.boards[boardId].length; i++){
  				if(this.ques.storage.boards[boardId][i]==widget) { 
  					this.ques.storage.boards[boardId].splice(i, 1) 
  				}
				}
				if(this.ques.storage.boards[boardId].length==0){
					delete this.ques.storage.boards[boardId];
					this.ques.storage.length--;
					this.stop();
					this.setState(0);
				}
			}
		},
		replaceQueId: function(id){
			var new_id = "board_" + id;
			if(this.ques && this.ques.storage && this.ques.storage.boards.board_null){
				this.ques.storage.boards[new_id] = this.ques.storage.boards.board_null;
				delete this.ques.storage.boards.board_null;
			}
		},
		abort: function(){
			this.request.abort();
			this.connectionState = true;
		},
		reset: function(){
			this.stop();
			this.setState(0);
			this.ques = this.initQues();
		},
		update: function(success, failed){
			var que = function(){
				if(this.ques && this.ques.storage && this.ques.storage.length > 0){
				  this.ques.pending = this.ques.storage;
					this.ques.storage = this.initStorageQue();
					return true;
				}
				return false
			}.b(this)();
			if(que){
				this.stop();
				this.setState(2);
				this.send(this.getUpdateBody(), 
					((success instanceof Function) ? success : function(request){
						this.succeded(request);
						if(this.board_list_bar) { Stixy.board.updateBoardList() };
					}.b(this)),
					((failed instanceof Function) ? failed : this.failed.b(this))
				);
			}
		},
		connections: [],
		connect: function(body, url, success, failure, force, content_type){
			if(!this.request) { return false }
			var request = this.request;
			var url = url || "/widgets/default/update"
			var method = (body) ? "POST" : "GET";
			try {
				if(this.connectionState || force){
					this.connectionState = false;
					request.open(method, url, true);
					request.setRequestHeader("Method", method+url+" HTTP/1.1");
					request.setRequestHeader("Content-Type", "application/xml");
					request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
					this.success = success;
					this.failure = failure;
					request.onreadystatechange = function(){
						if(request.readyState == 4){
							this.responseType = (request.getResponseHeader("Content-Type").search("xml") >= 0) ? "xml" : "text"
							this.responseContent = (this.responseType=="xml") ? request.responseXML : request.responseText;
							var error = (this.responseType=="xml") ? this.responseContent.getElementsByTagName("error")[0] : null;
							if(error){
								var errorType = Stixy.element.getNodeValue("type", error);
								var errorMessage = Stixy.element.getNodeValue("message", error);
								if(errorType=="LOST_SESSION"){
									Stixy.popup.open("/signin_again?popup=true",null,null,function(){
										this.connect(body, url, success, failure, true)
									}.bc(this)) 
								}else{
									alert("Error: " + errorMessage);
								}
							}else{
								try{
									if(this.success && (this.success instanceof Function) && request.status == 200) { this.success(request) }
									if(this.failure && (this.failure instanceof Function) && request.status != 200) { this.failure(request) }
								}catch(e){ }
								this.connectionState = true;
								this.sendNext();
							}
						}
					}.bc(this);
					request.send(body ? (typeof(body)=="object") ? Stixy.XML.fromObject(body) : body : null);
				}else{
					this.connections.push({body:body, url:url, success:success, failure:failure})
				}
			}
			catch(e) { return false }
			return true;
		},
		sendNext: function(){
			var next = this.connections.shift();
			if(next) { this.connect(next.body, next.url, next.success, next.failure) }
		},
		send: function(body, success, failed){
			this.connect(body, null, success, failed);
		},
		setState: function(state){
			this.state = state;
			Stixy.ui.pending(state==1||state==2);
			var new_name =	(state==1) ?	"save" :
 											(state==2) ?	"saving" :
																		"saved";
			var saveClasses = ["save","saving","saved"]
			for(var i=0; i<saveClasses.length; i++){
				Stixy.element.addClassName(Stixy.ui.base, new_name);
				Stixy.element.removeClassName(Stixy.ui.base, saveClasses[i]);
			}
		},
		failed: function(){
		  this.errorCount = this.errorCount || 0
	    var reset = function(){
        this.setState(1);
  			this.requestBody = null;
  	    if(this.ques && this.ques.sent){
			    this.ques.sent.eachProperty(function(board_id,board){
						board.eachProperty(function(widget_id, properties){
  						var widget = Stixy.widgets.getWidget(widget_id);
      	      widget.properties = widget.properties || {}
      			  widget.properties.merge(properties);
  					})
  				}.b(this));
  			  this.ques.storage = this.ques.storage || {}
  			  this.ques.storage.merge(this.ques.pending)
  			}
  			this.start();
	    }
			if(this.errorCount++ < 2){
			  reset.b(this)()
		  }else{
		    this.errorCount = 0;
		    //this.toggleAutoSave(false)
  			Stixy.popup.populate({ replace: 
  			  { 
  			    popup_content: '<h1>We have lost connection to the server!</h1>Your updates can\'t be saved to the server. Please make sure your computer is connected to the internet and try again. If you still can\'t save to the server, close this popup and copy any unsaved changes to your computers clipboard and try to reload the page. <p><b>Help us to improve Stixy.</b> If you think this is a bug and not related to your connection, file a bug by <a href="/support"   onclick="window.parent.Stixy.popup.openExternal(\'/support?message='+Stixy.XML.fromObject(this.getBoardBody(this.getUpdateBodyFromPendingQueue())) +'\'); return false;">sending a ticket</a> to our support team.',
  			    popup_buttons: '<%= escape_javascript(render( :partial => "/shared/popup/close_button")) %>' 
  			  }
  			});
  			Stixy.popup.listen('cancel', reset.b(this))
  			Stixy.popup.listen('close', reset.b(this))
		  }
		},
		succeded: function(request){
			var boardId = "board_" + Stixy.board.id;
			var currentBoard = request.responseXML.getElementsByTagName(boardId)[0];
			if(currentBoard){
				if(this.ques.storage){
					this.setState((this.ques.storage.length==0) ? 0:1);
				}
				var responseBody = currentBoard.getElementsByTagName("widget");
				for(var i=0; i<responseBody.length; i++){
					var item = responseBody[i];
					var newID = Stixy.element.getNodeValue("new_id", item);
					var oldID = Stixy.element.getNodeValue("old_id", item);
					if(this.ques && this.ques.pending){
					  for(var x=0; x<this.ques.pending.boards[boardId].length; x++){
  						var widget = this.ques.pending.boards[boardId][x];
  						if(widget.number===0 && widget.id==oldID){
  							widget.updateID("widget_"+newID);
  							widget.number = newID;
  							widget.announce("aftersave")
  						}
  					}
					}
				}
				if(this.ques && this.ques.pending && this.ques.pending.boards){
				  for(var i=0; i<this.ques.pending.boards[boardId].length; i++){
  					this.ques.pending.boards[boardId][i].announce("aftersave");
  				}
				}
				this.resetAfterSave();
			}
		},
		resetAfterSave: function(){
			this.requestBody = null;
			this.ques.pending = null;
		},
		replace: function(body, url, element_id, success, failed){
			this.connect(body, url, function(request){
				Stixy.html.replace(element_id, request.responseText);
				if(success) { success(request) }
			}.b(this), failed);
		},
		json: function(body, url, success, failed){
			this.connect(body, url, function(request){
				var result = Stixy.JSON.decode(request.responseText);
				Stixy.JSON.replaceHTML(result);
				Stixy.JSON.executeScript(result);
				if(success) { success(request) }
			}.b(this), failed);
		},
		getUpdateBody: function(){
			if(!this.requestBody){
				this.requestBody = Stixy.XML.fromObject(this.getBoardBody(this.getUpdateBodyFromPendingQueue()));
			}
			return this.requestBody;
		},
		getUpdateBodyFromPendingQueue: function(){
				var boards = {};
				this.ques.pending.boards.eachProperty(function(id,board_widgets){
					boards[id] = {}
					var board = boards[id];
					for(var i=0; i<board_widgets.length; i++){
						var widget = board_widgets[i];
						Stixy.extend(board, this.getWidgetBody(widget, widget.properties));
						widget.properties = null;
					}
				}.b(this));
				// Store until return from server with successful result.
				// Otherwise use to merge with widget.properties and try again
				this.ques.sent = boards;
				return boards;
		},
		getBoardBody: function(obj){
			return { 
				body: { 
					time: new Date().getTime(), 
					boards: obj
				} 
			}
		},
		getWidgetBody: function(widget, properties){
			var board_widget = { widget_id: widget.id } 
			board_widget.widget_id = widget.type
			Stixy.extend(board_widget, properties)
			var obj = {};
			obj[widget.id] = board_widget
			return obj
		}
	}
});