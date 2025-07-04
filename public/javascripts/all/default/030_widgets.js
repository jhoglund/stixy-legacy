Stixy.extend(Stixy, {
// Widgets			
// This needs to be rewritten. Why do wi have this object, and the instances object further down?		
	widgets: {
		cashed_widgets: [],
		getWidget: function(id){
			var result = (function(){
  			for(var i=0; i<this.cashed_widgets.length; i++){
    			if(this.cashed_widgets[i].number==id || this.cashed_widgets[i].id==id) { 
    		    return this.cashed_widgets[i] 
  				}
  			}
  			return false;
			}.b(this))();
			return result
		},
		removeWidgets: function(test){
			for(var i=0; i<arguments.length; i++){
				for(var x=0; x<this.cashed_widgets.length; x++){
					if(arguments[i]!=this.cashed_widgets[x]) { continue }
					this.cashed_widgets.splice(x,1);
				}
			}
		},
		removeAll: function(test){
			for(var i=0; i<this.cashed_widgets.length; i++){
				this.cashed_widgets[i].destroy();
			}
			this.cashed_widgets = [];
		},
		addWidget: function(widget){
			this.cashed_widgets.push(widget);
			widget.remove.listen("beforeremove", function(){
				this.removeWidget(widget)
			}.b(this));
			return widget;
		},
		removeWidget: function(widget){
			for(var i=0; i<this.cashed_widgets.length; i++){
				if(widget==this.cashed_widgets[i]) { this.cashed_widgets.splice(i, 1) }
			}
		}
	}
});

Stixy.extend(Stixy.widgets, {
	Base: function(){
	  this.destroy = function(){
			this.announce("beforedestroy");
			this.instances.unregister(this);
			this.deactivate();
		  this.element.parentNode.removeChild(this.element);
    	this.announce("afterdestroy");
		}
    this.initialize = function(name,element_id,attributes){
		  this.name = name;
	    this.element = Stixy.element.$ID(element_id) || null;
			this.id = (this.element) ? this.element.id || null : null;
			this.boardId = Stixy.board.id || null;
			this.attributes = attributes || {};
			this.lock(this.attributes["locked"]);
	    this.active = false;
			if(this.attributes["options"]===null) { this.optionbar = null }
	    if(this.id) { this.getIDNumber() }
	    this.properties = null;
	    // Features
	    if(this.focus !== null && this.attributes["focus"] !== false){ 
	      var focusSource = Stixy.element.$CN("focus",this.element);
	      if(focusSource){
	        this.focus = new Stixy.features.Focus(this, {source:this.element, target:focusSource[0]});
  				this.focus.listen("gotfocus", function(multipleSelected){
  					Stixy.element.addClassName(this.element,(this.locked ? "widget-selected-locked" : "widget-selected"));
  					if(!this.locked){ this.appendToMultiselect() };
  					if(this.optionbar){
  						if(multipleSelected){
  							this.optionbar.hide(this);
  						}else{
  							this.optionbar.show(this, false);
  						}
  					}
  				}.b(this));
  	      this.focus.listen("singlefocus", function(){
  					if(this.optionbar){
  						this.optionbar.show(this, false);
  					}
  	      }.b(this));
  	      this.focus.listen("lostfocus", function(){
  					Stixy.element.removeClassName(this.element,"widget-selected");
  					if(!this.locked){ this.removeFromMultiselect() };
  	        if(this.optionbar) { this.optionbar.hide(this) }
  	      }.b(this));
  	      this.focus.listen("activated", function(){
  	        Stixy.element.addClassName(this.element,"widget-activate");
  	      }.b(this));
  	      this.focus.listen("deactivated", function(){
  	        Stixy.element.removeClassName(this.element,"widget-activate");
  	      }.b(this));
  	      this.focus.listen("highlighted", function(){
  	        Stixy.element.addClassName(this.element,"widget-highlighted");
  	      }.b(this));
  	      this.focus.listen("delighted", function(){
  	        Stixy.element.removeClassName(this.element,"widget-highlighted");
  	      }.b(this));
  				this.global.multiselect.listen("beforereset",function(){
  					if(this.focus) this.focus.resetFocus();
  				}.b(this));
  				this.listen("beforeclone", function(){
  					this.focus.resetFocus();
  				}.b(this));
	      }
	    }
	    if(this.move !== null && this.attributes["move"] !== false){ 
	      this.move = new Stixy.features.Move(this, {source:this.element,target:this.global.multiselect.get()});
	      this.move.listen("beforemove", function(){
  				Stixy.element.addClassName(this.element,"widget-move-hover");
					var minimum = this.global.multiselect.getMinimumPositions();
					this.move.minX = minimum.x;
					this.move.minY = minimum.y;
	        this.copyWidgetToBoard = function(element, id, event){
						this.dragOutItem(element, id)
						Stixy.element.addClassName(element, "board-list-loading")
						var body = {}
						var board_id = "body_"+Stixy.board.getID();
						body[board_id] = {};
						for(var i=0; i<this.global.multiselect.items.length; i++){
							var widget = this.global.multiselect.items[i];
							widget.move.reset();
							Stixy.extend(body[board_id], Stixy.server.getWidgetBody(widget, {clone_to:id}));
						}
						var body_xml = Stixy.XML.fromObject(Stixy.server.getBoardBody(body));
						Stixy.server.send(body_xml, function(){
							Stixy.element.removeClassName(element, "board-list-loading")
						})
					}
					this.dragOverItem = function(element, id){
						Stixy.events.observe(element, "mouseup", this.copyWidgetToBoard.b(this,element,id))
						Stixy.element.addClassName(element, "board-list-dragover")
					}
					this.dragOutItem = function(element, id){
						Stixy.events.stopObserving(element, "mouseup", this.copyWidgetToBoard.b(this,element,id))
						Stixy.element.removeClassName(element, "board-list-dragover")
					}
					Stixy.ui.listen("mouseoverBoardListItem", this.dragOverItem.b(this))
					Stixy.ui.listen("mouseoutBoardListItem", this.dragOutItem.b(this))
	        this.focus.activate();
	      }.b(this));
				this.move.listen("aftermove", function(){
	        Stixy.element.removeClassName(this.element,"widget-move-hover");
	        Stixy.ui.unlisten("mouseoverBoardListItem", this.dragOverItem.b(this))
	        Stixy.ui.unlisten("mouseoutBoardListItem", this.dragOutItem.b(this))
					this.focus.deactivate();
	        if(this.move.updated) {
						for(var i=0; i<this.global.multiselect.items.length; i++){
							var item = this.global.multiselect.items[i];
							item.save({left:item.left(),top:item.top()})
						}
				  }
	      }.b(this));
	    }
	    if(this.resize !== null && this.attributes["resize"] !== false){ 
	      var resizeSource = Stixy.element.$CN("resizer",this.element);
				if(resizeSource){
	        this.resize = new Stixy.features.Resize(this, {minwidth:30,minheight:30,target:this.element, source:resizeSource[0]});
  	      this.resize.listen("beforeresize", function(){
  	        Stixy.element.addClassName(this.element,"widget-move-hover");
  	        this.move.stay = true;
  					this.focus.activate();
  	      }.b(this));
  	      this.resize.listen("afterresize", function(){
  	        Stixy.element.removeClassName(this.element,"widget-move-hover");
  	        this.move.stay = false;
  	        this.focus.deactivate();
  	        if(this.resize.updated) { this.save({width:parseInt(this.element.style.width),height:parseInt(this.element.style.height)}) }
  	      }.b(this));
	      }
	    }
	    if(this.remove !== null && this.attributes["remove"] !== false){ 
	      var removeSource = Stixy.element.$CN("remove",this.element);
	      if(removeSource){
  	      this.remove = new Stixy.features.Remove(this, {source:removeSource[0],target:this.element})
  	      this.remove.listen("beforeremove", function(){
  	        this.focus.resetFocus();
  					if(this.optionbar) { this.optionbar.hide(this) }
  					this.optionbar = null;
  					this.save({remove:true});
  	      }.b(this));
  	    }
	    }
	    if(this.hover !== null){ 
	      this.hover = new Stixy.features.Hover(this, {target:this.element});
	      this.hover.listen("enter", function(){
			    Stixy.element.addClassName(this.element,(this.locked ? "widget-hover-locked" : "widget-hover"));
	      }.b(this));
	      this.hover.listen("leave", function(){
					Stixy.element.removeClassName(this.element,(this.locked ? "widget-hover-locked" : "widget-hover"));	
	      }.b(this));
	    }
	    if(this.order !== null){ 
	      this.order = new Stixy.features.Order(this,{source:this.element, stay:this.attributes["stay"]});
	      this.order.listen("shuffle", function(){
					if(Stixy.ua.ie){
						this.global.multiselect.stackorder(this.order.id);
			  	}
					this.save({zindex:this.order.id});
	      }.b(this));
			}
	    if(this.text !== null && this.attributes["text"] !== false){ 
	      var editorSource = Stixy.element.$CN("editor",this.element);
	      if(editorSource){
	        this.text = new Stixy.features.Text(this, {source:editorSource[0]});
  				this.text.editable((!this.locked));
  	      this.text.listen("beforeedit", function(){
  					this.save({text:{value:this.text.getSource.b(this.text)}});
  	      }.b(this));
  				if(this.hover && Stixy.ua.gecko >= 1){
  					/* PATCH: Due to a refresh bug in Firefox 3, we have to recreate the selection after a class has been inserted or removed on a parent element of the text selection. */		
  	      	function refreshTextSelection(){
  						var selection = window.getSelection();
  						if(!selection.isCollapsed){
  							var range = selection.getRangeAt(selection.focusNode, 0);
  							if(!range.collapsed){
  								setTimeout(function(){
  									if(selection instanceof Selection){
  										if(!selection.isCollapsed) selection.collapseToStart();
  										selection.addRange(range);
  									}
  								}.b(this), 1)
  							}
  						}
  					}
  					this.hover.listen("afterleave", function(){
  						refreshTextSelection()
  					}.b(this));
  					this.hover.listen("afterenter", function(){
  						refreshTextSelection()
  					}.b(this));
  	      }
	      }
	    }
			this.listen("added", function(){
				this.save({left:this.left(),top:this.top()});
				this.save({width:parseInt(this.element.offsetWidth),height:parseInt(this.element.offsetHeight)});
				this.order.changeOrder();
	    }.b(this));
			this.listen("drop", function(){
	      this.focus.deactivate();
	      this.focus.giveFocus();
				this.focus.announce("deactivated")
				this.hover.announce("enter");
	      this.announce("added");
	    }.b(this));
			Stixy.events.observe(this.element, "mouseup", function(){ this.focus.announce("mousereleased") }.b(this));
	  }
	  this.instances.register(this);
	  return this;
	}
});
Stixy.widgets.Base.prototype.lock = function(state){ 
	this.locked = state || false;
	if(this.locked){
		this.removeFromMultiselect();
	}else{
		if(this.focus && this.focus.hasFocus){
			this.appendToMultiselect();
		}
	}
	if(this.focus && this.focus.hasFocus){
		Stixy.element.addClassName(this.element,(this.locked ? "widget-selected-locked" : "widget-selected"));
		Stixy.element.removeClassName(this.element,(!this.locked ? "widget-selected-locked" : "widget-selected"));
	}
	if(this.text){
		this.text.editable((!this.locked));
	}
}
Stixy.widgets.Base.prototype.left = function(){
	return ((this.focus && this.focus.hasFocus) ? this.global.multiselect.get().offsetLeft : 0) + this.element.offsetLeft;
}
Stixy.widgets.Base.prototype.top = function(){
	return ((this.focus && this.focus.hasFocus) ? this.global.multiselect.get().offsetTop : 0) + this.element.offsetTop;
}
Stixy.widgets.Base.prototype.offsetPosition = function(x,y){
  this.element.style.left = this.element.offsetLeft + x + "px";
	this.element.style.top = this.element.offsetTop + y + "px";
}
Stixy.widgets.Base.prototype.getOffsetPositions = function(){
	return {x:this.global.multiselect.get().offsetLeft + this.element.offsetLeft,
					y:this.global.multiselect.get().offsetTop + this.element.offsetTop};
}
Stixy.widgets.Base.prototype.appendToMultiselect = function(){
	this.offsetPosition(-this.global.multiselect.get().offsetLeft,-this.global.multiselect.get().offsetTop);
	this.global.multiselect.get().appendChild(this.element);
	this.global.multiselect.register(this);
}
Stixy.widgets.Base.prototype.removeFromMultiselect = function(){
	this.offsetPosition(this.global.multiselect.get().offsetLeft,this.global.multiselect.get().offsetTop)
	Stixy.ui.canvas_content.appendChild(this.element);
	this.global.multiselect.unregister(this);
}
Stixy.widgets.Base.prototype.setMultiselectMinimum = function(){
	this.global.multiselect.setMinimum(this.element.offsetLeft, this.element.offsetTop);
}

Stixy.widgets.Base.prototype.scrollIntoView = function(focus, edit){
	if(Stixy.ui && this.move){
	  var positions = {left:Math.max(0, (this.element.offsetLeft-(Stixy.ui.canvas.clientWidth/2)+(this.element.scrollWidth/2))),top:Math.max(0, (this.element.offsetTop-(Stixy.ui.canvas.clientHeight/2)+(this.element.scrollHeight/2)))};
		Stixy.ui.scrollToPosition(positions, 0.3)
		if(focus===true && this.focus){
			if(edit===true){
				this.order.changeOrder()
				this.focus.giveFocus()
			}else{
				this.focus.highlight()
			}
		}
	}
}

Stixy.widgets.Base.prototype.global = new function(){
  this.multiselect = {
		items: [],
	  length: 0,
		eachItem: function(f){
			for(var i=0; i<this.items.length; i++){
				f.call(this, this.items[i], i);
			}
		},
		stackorder: function(z){
			this.multilayer.style.zIndex = z;
			if(z < 0){ this.multilayer.style.zIndex = -this.multilayer.style.zIndex }
		},
		register: function(widget){
			this.items.push(widget);
			this.length++
			if(Stixy.ua.ie){
				this.stackorder((this.items.length > 1) ? Math.max(Number(widget.element.style.zIndex),Number(this.multilayer.style.zIndex)) : widget.element.style.zIndex);
	  	}
		},
	  unregister: function(widget){
			for(var i=0; i<this.items.length; i++){
				if(widget==this.items[i]) { this.items.splice(i, 1) }
	    }
			this.length--
	  },
		get: function(){
			if(!this.multilayer){
				this.multilayer = document.createElement("div");
				this.multilayer.style.cssText = "position:absolute;top:0;left:0;";
				Stixy.ui.canvas_content.appendChild(this.multilayer)
			}
			return this.multilayer;
	  },
	  reset: function(){
	    if(this.multilayer && !this.multilayer.removeChild){
	      try{
	        // DEBUG
  	      //new StixyError(new Error("Reset multilayer"), this)
	      }catch(e){}
	    }
			// First, test to see that this.multilayer exist and is a Node
			if(this.multilayer && this.multilayer.removeChild){
				this.announce("beforereset")
  			try{
	        Stixy.ui.canvas_content.removeChild(this.multilayer);
  	    }catch(e){ }
    	  
			}
			delete this.multilayer;
	  },
		getMinimumPositions: function(){
			var pos = {x:null,y:null};
			for(var i=0; i < this.items.length; i++){
				var x = this.items[i].element.offsetLeft + this.items[i].element.offsetWidth;
				var y = this.items[i].element.offsetTop + this.items[i].element.offsetHeight;
				pos.x = pos.x ? Math.min(pos.x, x) : x;
				pos.y = pos.y ? Math.min(pos.y, y) : y;
			}
			pos.x -= 10;
			pos.y -= 70;
    	return pos;
		}
	}
	Stixy.board.listen("unload", this.multiselect.reset.b(this.multiselect))
}

Stixy.widgets.Base.prototype.instances = new function(){
  this.items = [];
  this.length = 0;
	this.register = function(widget){
    this.items.push(widget);
		this.length++
  }
  this.unregister = function(widget){
		for(var i=0; i<this.items.length; i++){
			if(widget==this.items[i]) { this.items.splice(i, 1) }
    }
		this.length--
  }
}
Stixy.widgets.Base.prototype.rotate = function(){
  var _width = this.element.scrollWidth;
  var _height = this.element.scrollHeight;
  this.element.style.width = _height + "px";
  this.element.style.height = _width + "px";
  this.announce("afterrotate");
}
Stixy.widgets.Base.prototype.removeWidget = function(){
  this.remove.remove();
}
Stixy.widgets.Base.prototype.updateID = function(newID){
  this.id = newID;
  this.getIDNumber();
  this.element.setAttribute("id",this.id);
  this.announce("idupdated");
}
Stixy.widgets.Base.prototype.getIDNumber = function(){
  this.number = this.id.match(/widget_(\d+)/);
  this.number = (this.number) ? this.number[1] : 0;
  return this.number;
}
Stixy.widgets.Base.prototype.save = function(attr){
	if(!attr||this.attributes&&(this.attributes["save"]===null)) { return }
  if(!this.properties){
		Stixy.server.save(this) 
	}
  this.properties = this.properties || {};
  function _register(properties,attributes){
    attributes.eachProperty(function(name, value){
			properties[name] = (!properties[name] || (typeof attributes[name] != "object")) ? attributes[name] : _register(properties[name],attributes[name]);
		})
    return properties;
  }
  if(attr["remove"] && this.number==0){ 
    Stixy.server.removeFromQue(this) 
  }else{
    this.properties = _register(this.properties,attr);
  }
}
Stixy.widgets.Base.prototype.deactivate = function(){
	if(this.move)   { this.move.remove(1) }
	if(this.resize) { this.resize.remove(2) }
	if(this.hover)  { this.hover.remove(3) }
	if(this.order)  { this.order.remove(4) }
	if(this.text)   { this.text.remove(5) }
	if(this.focus)  { this.focus.remove(6) }
	delete this.move;
	delete this.resize;
	delete this.hover;
	delete this.order;
	delete this.text;
	delete this.focus;
}

Stixy.widgets.Base.prototype.addSibling = function(left, top, visible){
	this.announce("beforeclone")
	var clone = this.element.cloneNode(true);
	if(document.all){
		function removeEvents(source,target){
			var cached = Stixy.events.getCachedObserverForElement(source);
			for(var i=0; i<cached.length; i++){
				target.detachEvent("on" + cached[i].name, cached[i].observer)
			}		
		}
		removeEvents(this.element,clone)
		for(var i=0; i<this.element.all.length; i++){
			removeEvents(this.element.all(i),clone.all(i))
		}
	}
	clone.id = Stixy.tempID.get();
	clone.style.zIndex = (Number(this.element.style.zIndex) + 1);
	clone.style.left = (left || 20) + this.element.offsetLeft + "px";
	clone.style.top = (top || left || 20) + this.element.offsetTop + "px";
	clone.style.visibility = (visible===false) ? "hidden":"visible";
	this.element.parentNode.appendChild(clone);
	var widget = new this.constructor(clone.id);	
	widget.announce("added");
	return widget;
}

//Stixy.widgets.Base.prototype.upload = new Stixy.features.Upload;
Stixy.widgets.UploadCommon = function(){
	this.beforeStart = function(callback){
		var index = callback.files.length
		var offset = this.settings.widget_offset || [15,15];
		var clone_left = this.widget.left();
		var clone_top = this.widget.top();
		do {
			var file = callback.files.pop();
			this.register(this.widget, file);
			if(callback.files.length){
				this.widget = this.widget.addSibling(offset[0], offset[1], false);
				var inversed_index = index - callback.files.length;
				setTimeout(function(i){ 
					this.style.left = clone_left + (offset[0] * i) + "px";
					this.style.top = clone_top + (offset[1] * i) + "px";
					this.style.visibility = "visible" 
				}.b(this.widget.element, inversed_index), 300 * inversed_index);
			}
		} while(callback.files.length);
		// The space between "} while" is important for IE to work
	}
	this.start = function(callback){
		this.widget = this.getTarget();
	}
	this.finished = function(callback){
		Stixy.server.connect(null, this.settings.load_metadata_backend+callback.tempID+"?board_id="+Stixy.board.getID(), function(request){
			this.addAfterUpload(request.responseXML);
		}.b(this.widget));
	}
	this.fallback = function(result){
		this.widget.removeWidgetUploadButton();
		this.widget.addAfterUpload(result);
	}
}