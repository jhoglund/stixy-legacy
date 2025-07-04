try {
	var STIXY_ENV = "development" || "production";
	var StixyError = function(e,label){
		this.message = e.message;
		this.lineNumber = e.lineNumber;
		this.label = label;
		this.errors.push(this);
		if(STIXY_ENV=="development"){
			console.log(e)
			if(this.label){
				console.log(this.label);
			}
		}
	}
	StixyError.prototype = new Error;
	StixyError.prototype.name = "StixyError"
	StixyError.prototype.errors = new Array;
	StixyError.hasError = function(){
		return StixyError.prototype.errors.length > 0;
	}
}catch(e){ }

onerrors = function(){
	new StixyError(new Error("Unspecified Error"))
}

try {

	try{ document.execCommand('BackgroundImageCache', false, true) }catch(e){}

	var logger = {
		info: function(){
			if(window.dump) { dump(arguments[0]) }
		},
		debug: function(){
			if(STIXY_ENV=="development" && window.console) { console.log(arguments[0]) }
		},
		error: function(){
			if(STIXY_ENV=="development" && window.console) { alert(arguments[0]) }
			else if(window.console) { console.log(arguments[0]) }
		}
	}

	var console = console || { 
		log: function(){
			if(STIXY_ENV=="development") alert(arguments[0])
		}
	}

	Function.prototype.bc = function(obj){
		// Init object storage.
		if (!window.__objs){
		window.__objs = [];
		window.__funs = [];
		}
	
		// For symmetry and clarity.
		var fun = this;
	
		// Make sure the object has an id and is stored in the object store.
		var objId = obj.__objId;
		if (!objId) {
		__objs[objId = obj.__objId = __objs.length] = obj;
		}
		// Make sure the function has an id and is stored in the function store.
		var funId = fun.__funId;
		if (!funId) {
		__funs[funId = fun.__funId = __funs.length] = fun;
		}
		// Init closure storage.
		if (!obj.__closures) {
		obj.__closures = [];
		}
		// See if we previously created a closure for this object/function pair.
		var closure = obj.__closures[funId];
		if (closure) {
		return closure;
		}
		// Clear references to keep them out of the closure scope.
		obj = null;
		fun = null;
	
		// Create the closure, store in cache and return result.
		return __objs[objId].__closures[funId] = function (){
		return __funs[funId].apply(__objs[objId], arguments);
		}
	}
	Function.prototype.ub = function() {
		function o(s){
			if(s.__original_function) return o(s.__original_function)
			return s
		}
		return o(this);
	}
	Function.prototype.b = function() {
		var a = Array.prototype.splice.apply(arguments,[0,arguments.length]), o = a.shift(), m = this;
		var f = function() {
	    return m.apply(o, a.concat(Array.prototype.splice.apply(arguments,[0,arguments.length])));
	  }
		f.__original_function = m;
	  return f;
	}
	Function.prototype.be = function(o) {
	  var m = this;
		var f = function(e) {
	    return m.call(o, e || window.event);
	  }
		f.__original_function = m;
	  return f;
	}

	Object.prototype.__prototype_extension = false;
	Object.prototype.announce = function(){
		try{
			var args = [];
			for(var i=0; i<arguments.length; i++) args[i] = arguments[i];
			var type = args.shift();
			var e = this.__cashed_custom_events[type];
			var l = e.length;
			for(var i=0; i<l; i++){ 
				try{
					e[i].apply(null, args);
				}catch(e){ }
			}
		}catch(e){ }
	}
	Object.prototype.announce.__prototype_extension = true;
	Object.prototype.listen = function(type,f,debug){
		this.__cashed_custom_events = this.__cashed_custom_events || {};  
		this.__cashed_custom_events[type] = this.__cashed_custom_events[type] || [];
		var e = this.__cashed_custom_events[type];
		var l = e.length;
	  for(var i=0; i<l; i++){ if(e[i] && e[i].ub()==f.ub()) { return false } }
		e.push(f);
		return true
	}
	Object.prototype.listen.__prototype_extension = true;
	Object.prototype.unlisten = function(type,f,debug){
		try{
			var e = this.__cashed_custom_events[type];
			var l = e.length;
	  	for(var i=0; i<l; i++){ if(e[i] && e[i].ub()==f.ub()) { return e.splice(i, 1) } }
			return false;
		}catch(e){ }
	}
	Object.prototype.unlisten.__prototype_extension = true;
	Object.prototype.eachProperty = function(fn){
		for(var i in this){
			if(this[i].__prototype_extension||i.substr(0,2)=="__"){ continue };
			fn(i,this[i])
		}
	}
	Object.prototype.eachProperty.__prototype_extension = true;
	Object.prototype.__unique_id_index = 0;
	Object.prototype.get_unique_id = function(){
		this.__unique_id = this.__unique_id || ("_uid_" + Object.prototype.__unique_id_index++);
		return this.__unique_id;
	}
	Object.prototype.get_unique_id.__prototype_extension = true;
	Object.prototype.getOrCreate = function(o,d){
		this[o] = this[o] || d || {};
		return this[o]
	}
	Object.prototype.getOrCreate.__prototype_extension = true;

	var Stixy = {
		state: new function(){
			this.ready = false;
			this.errors = [];
			this.setError = function(error){
				logger.debug(error)
				this.errors.push(error);
			}.b(this);
			this.hasErrors = function(){
				return this.errors.length > 0;
			}.b(this);
		},
		extend: function(destination, source) {
		  source.eachProperty(function(property,value){
				destination[property] = source[property];
		  })
		  return destination;
		}
	}

	////////////
	// Events //
	////////////

	Stixy.extend(Stixy, {
		events: {
			halt: function(e){
				if(e.stopPropagation){
					e.stopPropagation();
				}else{
	      	event.cancelBubble = true;
	      }
			},
			related: function(e,t){
				var r = (e.relatedTarget!=undefined) ? e.relatedTarget : (e.type=="mouseout") ?  e.toElement : e.fromElement;
				while(r){
					if(r==t){ return true }
					else{ r = r.parentNode}
				}
				return false;
			},
			contained: function(e,t){
				return Stixy.element.contained(this.element(e),t);
			},
			element: function(e) {
		    return e.target || e.srcElement;
		  },
		  stop: function(e) {
				if(!e) { return };
				if(e.preventDefault){
		      e.preventDefault();
		      e.stopPropagation();
		    }else{
		      e.returnValue = false;
		      e.cancelBubble = true;
		    }
		  },
			before_unload_filters: [],
			observers: {},
			_addToCache: function(e, n, o, c, debug){
				var n = this.observers.getOrCreate(n),c = n.getOrCreate(c),f = c.getOrCreate(o.ub().get_unique_id(), []);
				for(var i=0; i<f.length; i++){ 
					if(f[i].element==e){ return false } 
				}
				f.push({element:e,func:o});
				return o;
			},
			_getFromCache: function(e, n, o, c){
				try{ 
					var a = this.observers[n][c][o.ub().get_unique_id()]
					if(a){
						l = a.length;
						for(var i=0; i<l; i++){
							if(a[i].element==e) return a[i].func;
						}
					}
				}
				catch(e){ new StixyError(e); return false; }
			},
			_removeFromCache: function(e, n, o, c, debug){
				try{ 
					var a = this.observers[n][c][o.ub().get_unique_id()]
					if(a){
						l = a.length;
						for(var i=0; i<l; i++){
							if(a[i].element==e){
								a.splice(i,1);
								if(a.length==0){
									delete this.observers[n][c][o.ub().get_unique_id()];
								}
								break;
							}
						}
					}
				}
				catch(e){ new StixyError(e); return false; }
			},	
		  getCachedObserverForElement: function(e){
				var cached = [];
				this.observers.eachProperty(function(tn,tp){
					tp.eachProperty(function(cn,cp){
						cp.eachProperty(function(fn,fp){
							for(var i=0; i<fp.length; i++){
								if(fp[i].element==e){
									cached.push({element:fp[i].element,name:tn,observer:fp[i].func,capture:cn});
								}
							}
						});
					});
				});
				return cached;
			},
		  unloadCache: function() {
				var s = this._removeObserver.b(this);
				this.observers.eachProperty(function(tn,tp){
					tp.eachProperty(function(cn,cp){
						cp.eachProperty(function(fn,fp){
							for(var i=0; i<fp.length; i++){
								s(fp[i].element,tn,fp[i].func,(cn=="true"));
							}
						});
					});
				});
		    this.observers = {};
		  },
			before_unload_filters: [],
			beforeUnloadExecute: function(){
				for(var i=0; i<this.before_unload_filters.length; i++){
					this.before_unload_filters[i]();
				}
			},
			beforeUnload: function(fun){
				this.before_unload_filters.push(fun)
			},
		  observe: function(e, n, o, c, debug) {
		    var c = c || false;
		    if (n == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || n.attachEvent)) { n = 'keydown' }
				if(e.addEventListener) {
					if(e===window && n=="ready"){ n = navigator.appVersion.match(/Konqueror|Safari|KHTML/) ? "load" : "DOMContentLoaded" }
					var o = this._addToCache(e, n, o, c, debug);
		    	if(o){ e.addEventListener(n, o, c) };
				}else if(e.attachEvent){
					if(e===window && n=="ready"){ n = "load" }
					if(e==window && n=="mouseup") { e = document }
					var r = this._addToCache(e, n, o, c);
			  	if(r){ e.attachEvent('on' + n, o) };
		    }
		  },
		  stopObserving: function(e, n, o, c, debug) {
				var c = c || false;
				this._removeObserver(e, n, this._getFromCache(e, n, o, c), c);
				return this._removeFromCache(e, n, o, c, debug)
		  },
			_removeObserver: function(e, n, o, c) {
				if(n == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || e.detachEvent)) { n = 'keydown' }
				if(e.removeEventListener){
					if(o){ e.removeEventListener(n, o, c) };
		    }else if(e.detachEvent){
					if(e==window && n=="mouseup") { e = document }
		      if(o){ e.detachEvent('on' + n, o) };
		    }
		  },
			activeKeys: [],
			setKey: function(key, add){
				if(add!==false){
					this.activeKeys[key] = true;
				}else{
					this.activeKeys[key] = null;
				}
			}
		}
	});

	/////////////////////
	// Element methods //
	/////////////////////

	Stixy.extend(Stixy, {
		element: {
			baseDocument: document,
			$ID: function(element, base) {
				try{
					return (typeof(element)=="string") ? ((base||Stixy.element.baseDocument).getElementById(element) || Stixy.widgets.Optionbar.frame.window.doc.getElementById(element)) : element;
				}catch(e){
					return null;
				}
			},
			addClassName: function(element, rule) {
		    element.className = element.className + " " + rule;
		  },
			removeClassName: function(element, rule) {
		    element.className = element.className.replace(new RegExp("(^||( ))"+rule+"([\d\w]||$||( ))","g"),"$1"+"$2");
		  },
	    replaceClassName: function(element,oldrule,newrule){
				var newrule = newrule || oldrule;
				setTimeout(function(){
					element.className = element.className.replace(new RegExp("(^||( ))"+oldrule+"([\d\w]||$||( ))","g"),"$1"+newrule+"$2");
				}.b(this), 1)
	    }
		}
	});


	Stixy.extend(Stixy, {
		features: {
			Base: function(widget, attributes){
			  this.widget = widget;
			  this.target = attributes["target"] || attributes["source"] || null;
			  this.source = attributes["source"] || attributes["target"] || null;
				this.observe = function(target, eventName, func, phase){
					Stixy.events.observe(target, eventName, func, phase);
				}
				this.stopObserving = function(target, eventName, func, phase){
					Stixy.events.stopObserving(target, eventName, func, phase);
				}
			}
		}
	});

	Stixy.features.Move = function(widget, attributes){
		Stixy.features.Base.call(this, widget, attributes)
		this.offsetX = 0;
	  this.offsetY = 0;
		this.left = 0;
	  this.top = 0;
		this.startX = this.target.offsetLeft;
		this.startY = this.target.offsetTop;
		this.setX = function(value){
			this.target.style.left = value + "px"
		}
	  this.setY = function(value){
			this.target.style.top = value + "px"
		}
		this.startMove = function(event){
	    Stixy.events.stop(event);
			this.startX = this.target.offsetLeft;
			this.startY = this.target.offsetTop;
			this.offsetX = (event.clientX - this.startX);
	    this.offsetY = (event.clientY - this.startY);
	    this.announce("beforemove", event);
			this.observe(document, "mousemove",  this.move.be(this));
	    this.observe(document, "mouseup",  this.stopMove.be(this));
	  }
	  this.move = function(event){
			this.announce("move");
			Stixy.events.stop(event);
	    this.x = event.clientX - this.offsetX;
	    this.y = event.clientY - this.offsetY;
	    var pointer = [this.x,this.y];
	    if(this.lastPointer && (this.lastPointer[0] == pointer[0] && this.lastPointer[1] == pointer[1])) { return }
	    this.lastPointer = pointer;
			this.setX(pointer[0]);
	    this.setY(pointer[1]);
	  }
	  this.stopMove = function(event){
	    this.stopObserving(document, "mousemove",  this.move);
	    this.stopObserving(document, "mouseup",  this.stopMove);
	    this.announce("aftermove");
	  }
	  this.observe(this.source, "mousedown",  this.startMove.be(this));
	}

	Stixy.features.Hover = function(widget, attributes){
		Stixy.features.Base.call(this, widget, attributes)
	  this.mouseEnter = function(event){
	    if(!Stixy.events.related(event, this.target)){
	      this.announce("enter");
	    }
	  }
	  this.mouseLeave = function(event){
	    if(!Stixy.events.related(event, this.target)){
	      this.announce("leave");
	    }
	  }
		this.observe(this.target, "mouseover", this.mouseEnter.be(this));
		this.observe(this.target, "mouseout", this.mouseLeave.be(this));
	}

	Stixy.widgets = {
		Base: function(){
	    this.initialize = function(name,element_id,attributes){
				this.name = name;
		    this.element = Stixy.element.$ID(element_id) || null;
				this.id = (this.element) ? this.element.id || null : null;
				this.boardId = null;
				this.attributes = attributes || {};
		    this.active = false;
				this.optionbar = null;
		    this.properties = null;
		    this.move = new Stixy.features.Move(this, {target:this.element,minX:this.moveMinX(),minY:this.moveMinY()});
		    this.move.listen("aftermove",function(){
					document.cookie = "note_x=" + this.element.offsetLeft;
					document.cookie = "note_y=" + this.element.offsetTop;
				}.b(this))
				this.hover = new Stixy.features.Hover(this, {target:this.element});
	      this.hover.listen("enter", function(){
	        Stixy.element.addClassName(this.element,"widget-hover");
	      }.b(this));
	      this.hover.listen("leave", function(){
	        Stixy.element.removeClassName(this.element,"widget-hover");
	      }.b(this));
		  }
		  return this;
		}
	};
	Stixy.widgets.Base.prototype.moveMinX = function(){ return this.element.clientWidth-10 }
	Stixy.widgets.Base.prototype.moveMinY = function(){ return this.element.clientHeight-10 }

	Stixy.widgets.Note = function(element_id,attributes){
		this.constructor = Stixy.widgets.Note;
		this.value = element_id;
		this.attributes = attributes || {};
	  this.type = 1;
		this.activate = function(){
		  Stixy.widgets.Base.call(this)
		  this.initialize("note",element_id,this.attributes);
		}
		this.activate();
	}
	Stixy.widgets.Note.prototype = new Stixy.widgets.Base;	
	Stixy.events.observe(window,"DOMContentLoaded",function(){
		Stixy.announce("ready")
	});
		

}catch(e){
	new StixyError(e);
}