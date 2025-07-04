var STIXY_FILE_GENERATED_AT = 'Mon Oct 26 14:03:11 +0100 2009';
var STIXY_ENV = 'test';
try {
	var StixyError = function(e,label){
		this.message = e.message;
		this.lineNumber = e.line || e.lineNumber;
		this.label = label;
		this.version = STIXY_FILE_GENERATED_AT;
		this.errors.push(this);
		if(STIXY_ENV=="production"){
			this.post(this.message, this.label, this.version)
		}else{
			if(window.console){
				if(this.label){
					console.log(this.lineNumber + ': ' + this.label);
				}
				throw e;
			}else{
				alert(this.label + ' (' + e.lineNumber + '): ' + e.message )
			}
		}
	}
	StixyError.prototype = new Error;
	StixyError.prototype.name = "StixyError"
	StixyError.prototype.errors = new Array;
	StixyError.prototype.server = (function(){
	  var xmlhttp;
	  try { xmlhttp = new ActiveXObject("Msxml2.XMLHTTP"); }
	  catch (e) { try { xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); }
	  catch (e) { try { xmlhttp = new XMLHttpRequest(); }
	  catch (e) { xmlhttp = false; }}}
	  if(!xmlhttp) { return null }
	  return xmlhttp;
	})()
	StixyError.prototype.post = function(){
		try {
			this.server.abort();
			this.server.open("POST", "/resources/log", true);
			this.server.setRequestHeader("Method", "POST/resources/log HTTP/1.1");
			this.server.setRequestHeader("Content-Type", "application/xml");
			this.server.setRequestHeader("X-Requested-With", "XMLHttpRequest");
			this.server.send("<body><version>"+this.version+"</version><message>"+this.message+"</message><label>"+(this.label||"")+"</label><line>"+this.lineNumber+"</line></body>");
		}catch(e){}
	}
	StixyError.hasError = function(){
		return StixyError.prototype.errors.length > 0;
	}
}
catch(e){ }
onerrors = function(){
	new StixyError(new Error("Unspecified Error"))
}
try {

try{ document.execCommand('BackgroundImageCache', false, true) }catch(e){}

//var logger = {
//	info: function(){
//		if(window.dump) { dump(arguments[0]) }
//	},
//	debug: function(){
//		if(STIXY_ENV=="development" && window.console) { console.log(arguments[0]) }
//	},
//	error: function(){
//		if(STIXY_ENV=="development" && window.console) { alert(arguments[0]) }
//		else if(window.console) { console.log(arguments[0]) }
//	}
//}

if(STIXY_ENV!="development"){
  if(!window.console){
    window.console = {
  	  log: function(){ }
  	}
  }
}

Function.prototype.bc = function(obj){
	try{
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
	}catch(e){ 
		if(!o.__hasError){
			o.__hasError = true;
			new StixyError(e) ;
		}
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
    try{
			return m.apply(o, a.concat(Array.prototype.splice.apply(arguments,[0,arguments.length])));
  	}catch(e){ 
			if(!o.__hasError){
				o.__hasError = true;
				new StixyError(e) ;
			}
	 	}
	}
	f.__original_function = m;
  return f;
}
Function.prototype.be = function(o) {
  var m = this;
	var f = function(e) {
    try{
    	return m.call(o, e || window.event);
  	}catch(e){ 
			if(!o.__hasError){
				o.__hasError = true;
				new StixyError(e) ;
			}
		}
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
				if(e.length != l){
					l = e.length;
					i--;
				}
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
  	for(var i=0; i<l; i++){ 
			if(e[i] && e[i].ub()==f.ub()) { return e.splice(i, 1) } 
		}
		return false;
	}catch(e){ }
}
Object.prototype.unlisten.__prototype_extension = true;
Object.prototype.eachProperty = function(fn){
	for(var i in this){
		if(this[i]===undefined){ continue };
		if(this[i].__prototype_extension||i.substr(0,2)=="__"){ continue };
		try{
			fn(i,this[i])
		}catch(e){
			continue
		}
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
  benchmark: function(label,scope,fn){
    var start = new Date
    fn.b(scope)()
    console.log(label, new Date - start)
  },
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
	tempID: {
		id: 1, 
		get: function(){
			return "temp_" + new Date().getTime() + this.id++;
		}
	},
	session: {
		// We need to store the session_id and if a user is autorized or not in the cookie.
    // This is so we can use it on the client side. The session_id is used by the flash upload,
    // and the authorized key is used for board navigation. None are a security risk.
    // The authorized key is only used to display the right info to a user. One can't alter it
    // and gain access to none authorized info. The session is can be retrived by a user anyway, by
    // decoding the cookie using base64.
    // Read about cookie sesions in rails at: http://www.neeraj.name/blog/articles/834-how-cookie-stores-session-data-in-rails
    // The session_id and the authorized key are set in a before_filter (set_js_cookies) in app/controllers/application.rb
    id: (function(){ 
		  var match = document.cookie.match(/stixy_sid=(\S*?)(?:\;|$|\s)/);
		  return match ? match[1] : null 
		})(), 
		getID: function(){
			return this.id;
		},
		isAuthorized: function(){
		  return !(document.cookie.match(/stixy_authorized=true/) == null);
		},
		getDomainCookies: function(){
			// Returns the cookis for the domain encoded as a query string
			return encodeURI(document.cookie.replace(/; /g, "&"))
		}
	},
	platform: (function(){
		var platforms = [["mac","mac"],["pc","win"],["linux","linux"]];
	  var o={
	      pc:false,
	      mac:false,
	      linux:false,
	      other:true
	  };
		for(var i=0; i<platforms.length; i++){
			var test = new RegExp(platforms[i][1],"ig").test(window.navigator.platform)
			if(test){
				o[platforms[i][0]] = true;
				o.other = false;
				break
			}
		}
		return o
	})(),
	ua: (function(){
	  // # TODO: Rewrite!!
	  var o={
	      ie:false,
	      opera:false,
	      firefox:false,
	      gecko:false,
	      webkit:false,
	      safari:false,
	      chrome:false,
	      mobile: false 
	  };
	  var ua=navigator.userAgent, m, v;
	  var chrome = ua.match(/Chrome\/(\S*)/)
	  if(chrome) {
	    o.chrome = chrome[1]
	  } else if ((/KHTML/).test(ua)) {
	      o.webkit=1;
	  }
	  m=ua.match(/AppleWebKit\/([^\s]*)/);
	  if (m&&m[1]) {
	      o.webkit=parseFloat(m[1]);
	      m=ua.match(/NokiaN[^\/]*/)
	      v=ua.match(/Version\/(\S*)/)
	      if (/ Mobile\//.test(ua)) {
	          o.mobile = "Apple"; // iPhone or iPod Touch
        } else if (m) {
	          o.mobile = "NokiaN95"; // iPhone or iPod Touch
        } else if (v) {
  	      o.minor = v[1].split('.');
          o.major = parseInt(o.minor);
          o.safari = true;
	      }
	  }
	  if (!o.webkit) { // not webkit
	      m=ua.match(/Opera[\s\/]([^\s]*)/);
	      if (m&&m[1]) {
    	      o.minor = m[1].split('.');
            o.major = parseInt(o.minor);
            o.opera = true;
	          if(ua.match(/Opera Mini[^;]*/)) {
	              o.mobile = true; // ex: Opera Mini/2.0.4509/1316
	          }
	      } else { // not opera or webkit
	          m=ua.match(/MSIE\s([^;]*)/);
	          if (m&&m[1]) {
	              o.minor = m[1].split('.');
                o.major = parseInt(o.minor);
        	      o.ie = true;
	          } else { // not opera, webkit, or ie
	              m=ua.match(/Gecko\/([^\s]*)/);
	              if (m) {
	                  o.gecko = true; // Gecko detected, look for revision
	                  m=ua.match(/rv:([^\s\)]*)/);
	                  if (m&&m[1]) {
	                    v = m[1].split('.')
      	              o.minor = v;
                      o.major = parseFloat(parseInt(v[0]) + (parseInt(v[1]) / 10));
	                  }
	              }
	              m=ua.match(/Firefox\/([^\s]*)/);
	              if (m) {
	                  o.firefox = true; // Gecko detected, look for revision
	                  if (m&&m[1]) {
	                    v = m[1].split('.')
      	              o.minor = m[1].split('.');
                      o.major = o.minor[0];
	                  }
	              }
	              
	          }
	      }
	  }
	  return o;
	})(),
	path: function(root, ext){
	  var root = root || '/resources/default/';
	  var ext = ext || '';
	  var browser = 'other';
	  if(Stixy.ua.ie && (Stixy.ua.major==7 || Stixy.ua.major==8)){
      browser = 'ie_7';
	  }else if(Stixy.ua.ie==true && Stixy.ua.major==6){
	    browser = 'ie_6';
	  }else if(Stixy.ua.ie){
	    browser = 'ie_old';
	  }else if(Stixy.ua.safari){
	    browser = 'safari';
	  }else if(Stixy.ua.chrome){
	    browser = 'chrome';
	  }else if(Stixy.ua.gecko){
	    browser = 'firefox';
	  }
	  return [root,browser,ext].join('')	  
	},
	detbug_time: new Date,
	openExternalWindow: function(uri){
		open(uri, "StixyExternalWindow");
	},
	nothing: function(){},
	extend: function(destination, source) {
		if(destination && source){
		  source.eachProperty(function(property,value){
				destination[property] = source[property];
		  })
		}
	  return destination;
	}
}
Stixy.ua.unless = function(regExp){
  if(navigator.userAgent.match(regExp)){
    var json = Stixy.JSON.decode(unescape('%7B%22replace%22:%20%7B%22popup_content%22:%20%22%3Ch2%20style=%5C%22margin:10px%200%200;%5C%22%3EThis%20feature%20is%20not%20supported%20by%20your%20browser%3C/h2%3E%3Cp%3E%5CtWe%20suggest%20that%20you%20install%20the%20latest%20version%20of%20Firefox%20right%20away,%20to%20get%20the%20best%20possible%20compatibility%20with%20Stixy.%20Get%20your%20copy%20at%20%3Ca%20href=%5C%22http://getfirefox.com/%5C%22%5Cttitle=%5C%22Get%20Firefox%20-%20Web%20browsing%20redefined.%5C%22%3Ehttp://getfirefox.com/%3C/a%3E%3C/p%3E%3Cp%3EPlease%20contact%20us%20at%20%3Ca%20href=%5C%22mailto:support@stixy.com%5C%22%3Esupport@stixy.com%3C/a%3E%20if%20you%20have%20any%20questions.%3C/p%3E%3Cp%20style=%5C%22text-align:center;margin-top:28px;%5C%22%3E%5Ct%20%5Ct%3Ca%20href=%5C%22http://getfirefox.com/%5C%22%5Cttitle=%5C%22Get%20Firefox%20-%20Web%20browsing%20redefined.%5C%22%3E%3Cimg%5Ctsrc=%5C%22http://www.mozilla.org/products/firefox/buttons/getfirefox_large2.png%5C%22%5Ctwidth=%5C%22178%5C%22%20height=%5C%2260%5C%22%20border=%5C%220%5C%22%20alt=%5C%22Get%20Firefox%5C%22%3E%3C/a%3E%3C/p%3E%22%7D%7D'))
    Stixy.extend(json.replace, Stixy.JSON.decode(unescape('%7B%22popup_buttons%22:%20%22%3Csx:button%20onmouseover=%5C%22Stixy.events.stop(event)%5C%22%20onmousedown=%5C%22Stixy.events.stop(event)%5C%22%3E%3Csx:i%3E&nbsp;%3C/sx:i%3E%3Csx:l%3E%3Csx:p%3E&nbsp;%3C/sx:p%3E%3C/sx:l%3E%3Csx:r%3E%3Csx:p%3E&nbsp;%3C/sx:p%3E%3C/sx:r%3E%3Csx:t%3E%3Ca%20class=%5C%22button-label%5C%22%20href=%5C%22%23%5C%22%20onclick=%5C%22Global.popup.close();%20return%20false;%5C%22%3EClose%3C/a%3E%3C/sx:t%3E%3C/sx:button%3E%22%7D')))
    Stixy.popup.populate(json, 500,300)
    return false;
  }
  return true;
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
			try{
				var r = (e.relatedTarget!=undefined) ? e.relatedTarget : (e.type=="mouseout") ?  e.toElement : e.fromElement;
				while(r){
					if(r==t){ return true }
					else{ r = r.parentNode }
				}
			}catch(e){}
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
	  fire: function(element, eventName, memo) {
      if (element == document && document.createEvent && !element.dispatchEvent){
        element = document.documentElement;
      }
      var event;
      if(document.createEvent) {
        event = document.createEvent("HTMLEvents");
        event.initEvent(eventName, true, true);
      } else {
        event = document.createEventObject();
        event.eventType = eventName;
      }
      event.eventName = eventName;
      event.memo = memo || { };
      if (document.createEvent) {
        element.dispatchEvent(event);
      } else {
        element.fireEvent(event.eventType, event);
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
			try{
				if(e && e.addEventListener) {
					if(e===window && n=="ready"){ n = navigator.appVersion.match(/Konqueror|Safari|KHTML/) ? "load" : "DOMContentLoaded" }
					var o = this._addToCache(e, n, o, c, debug);
		    	if(o){ e.addEventListener(n, o, c) };
				}else if(e && e.attachEvent){
					if(e===window && n=="ready"){ n = "load" }
					if(e==window && n=="mouseup") { e = document }
					var r = this._addToCache(e, n, o, c);
			  	if(r){ e.attachEvent('on' + n, o) };
		    }
	  	}catch(e){ 
				if(!o.__hasError){
					o.__hasError = true;
					new StixyError(e) ;
				}
			}
		},
	  stopObserving: function(e, n, o, c, debug) {
			var c = c || false;
			this._removeObserver(e, n, this._getFromCache(e, n, o, c), c);
			return this._removeFromCache(e, n, o, c, debug)
	  },
		_removeObserver: function(e, n, o, c) {
			if(n == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || e.detachEvent)) { n = 'keydown' }
			if(e && e.removeEventListener){
				if(o){ e.removeEventListener(n, o, c) };
	    }else if(e && e.detachEvent){
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
				return (typeof(element)=="string") ? (base||Stixy.element.baseDocument).getElementById(element) : element;
			}catch(e){
				return null;
			}
		},
		$CN: function(className, parentElement) {
			try{
				if(parentElement.getElementsByClassName){
					return parentElement.getElementsByClassName(className)
				}else{
					var children = parentElement.getElementsByTagName('*'), elements = [];
					for(var i=0; i<children.length; i++){
						if(children[i].className.match(new RegExp("(^|\\s)" + className + "(\\s|$)"))){
							elements.push(children[i]);
						}
					}
				  return elements;
				}
			}catch(e){ }
		},	
		$nsID: function(idName, nameSpaceName, parentElement, debug){
			try{
				var tags = parentElement.getElementsByTagName("*");
				for(var i=0; i<tags.length; i++){
					var id = tags[i].getAttribute((nameSpaceName||"sx")+":id", 2);
					if(id){
						if(id==idName){
							return tags[i];
						}
					}
				}
				return null;
			}catch(e){
				return null;
			}
		},
		$nsTags: ((function(){
			if(document.namespaceURI===undefined){
				return function(tagName, nameSpaceName, parentElement){
					parentElement = parentElement || document
					return parentElement.getElementsByTagName(tagName)
				}
			}else{
				return function(tagName, nameSpaceName, parentElement){
					parentElement = parentElement || document
					return parentElement.getElementsByTagName(nameSpaceName + ":" + tagName)
				}
			}
		})()),
		$nsTag: function(tagName, nameSpaceName, parentElement){
			var tags = this.$nsTags(tagName, nameSpaceName, parentElement);
			if(tags){
				tags = tags[0];
			}
			return tags;
		},
		$A: function(item) {
		  if(!item){
				return [];
			}else if(item.splice){
				// Test to see if item is already an array. Using "instanceof" to test to see if item is an array causes IE to leak memory
				return item;
			}else{
		    var results = [];
				if(item.length>0) {
		    	for (var i = 0; i < item.length; i++) results.push(item[i]);
				} else {
					results.push(item);
				}
		    return results;
		  }
		},
		getNodeValue: function(name, base){
			return base.getElementsByTagName(name)[0].firstChild.nodeValue;
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
    },
    hasClassName: function(element,rule){
      return (element.className.search(new RegExp("(^|| )"+rule+"([\d\w]||$|| )","g"))>=0) ? true:false;
    },
    toggleClassName: function(element, rule){
      if(this.hasClassName(element, rule)){
        this.removeClassName(element, rule);
				return false;
      }else{
        this.addClassName(element, rule);
				return true;
      }
    },
    toggleDisplay: function(element, state){
			if(element) element.style.display = state==true ? "block" : "none";
    },
		positionedOffset: function(element, prop, stopElement){
	    var val = 0;
	    do{
	      if(element==stopElement) break;
	      val += element[prop] || 0;
	    }while(element = element.offsetParent);
			return val
		},
		remove: function(element){
			try{
  			return element.parentNode.removeChild(element);
      }catch(e){ new StixyError(e, "004_elements.js line 112") }
		},
		discardElement: function(element) {
			this.bin = this.bin || function(){
				var bin = document.createElement("div");
        bin.style.display = "none";
        document.body.appendChild(bin);
					return bin;
			}();
			this.bin.appendChild(element);
		  this.bin.innerHTML = "";
		},
		contained: function(source,target){
		  if(source && target){
		    if(target.split){
  				var target = target.toUpperCase()
  				while(source){
  					if(source.tagName==target){ return source }
  					else{ source = source.parentNode}
  				}
  			}else{
  				while(source){
  					if(source==target){ return true }
  					else{ source = source.parentNode}
  				}
  			}
		  }
			return false;
		},
		setOpacity: function(source, value){
		  if(source.filters){
  			source.filters.item(0).Opacity = value * 100
  		}else{
  			source.style.opacity = value;
  		}
		},
		getOpacity: function(source){
		  if(source.filters){
  			return parseFloat((source.filters.item(0).Opacity / 100)||0);
  		}else{
  			return parseFloat(document.defaultView.getComputedStyle(source,null).getPropertyValue("opacity"));
  		}
		},
		form: {
			elementsToObject: function(form, return_elements){
				function dig(names, object, value){
					var current = object || {}
					var name = names.shift()
					current[name] = (names.length) ? dig(names, current[name], value) : value;
					return current;
				}
				var root = {}
				for(var i=0; i < form.elements.length; i++){
					var element = form.elements[i];
					if(element.name){
						var names = element.name.match(/[^\]\[]+/g);
						if(names){
							var value = return_elements ? element : this.getValue(element);
							if(value!==false){
								root = dig(names, root, value)
							}
						}
					}
				}
				return root
			},
			elementsToQueryString: function(form){
				var root = []
				for(var i=0; i < form.elements.length; i++){
					var element = form.elements[i];
					if(element.name){
						var value = this.getValue(element);
						if(value!=false){
							root.push(encodeURI(element.name + "=" + value))
						}
					}
				}
				return root.join("&");
			},
			getValue: function(field){
				var type = field.type.toLowerCase();
				if(type=="checkbox" || type=="radio"){
					return field.checked ? "1" : "0";
				}
				return field.value;
			},
			setValue: function(field,value){
				var fieldName = field.tagName.toLowerCase();
				var type = field.type.toLowerCase();
				if(fieldName=="select"){
					var options = field.options;
					for(var i=0; i<options.length; i++){
						if(options[i].value==value){
							options[i].selected = true
							break;
						}
					}
				}else if(type=="checkbox" || type=="radio" ){
					field.checked = value;
				}else{
					field.value = value;
				}
			},
			setFieldProperty: function(field, property, value){
				field[property] = value;
			},
			setFieldsProperty: function(fields, property, value){
				for(var i=0; i<fields.length; i++){
					if(fields[i]) this.setFieldProperty(fields[i], property, value);
				}
			}
		}
	}
});

Stixy.extend(Stixy, {
	html: {
		clear: function(element){
			Stixy.element.$ID(element).innerHTML = "";
		},
		replace: function(parent, content){
			(parent.substr ? Stixy.element.$ID(parent) : parent).innerHTML = content;
		},
		remove: function(element, content){
			var source = Stixy.element.$ID(element);
			try{
        source.parentNode.removeChild(source);
      }catch(e){ new StixyError(e, "005_str_html_xml.js line 13") }
		},
		insert_bottom: function(parent, str){
			var element = Stixy.element.$ID(parent);
			var child = this.parse(str);
			var firstChild = element.getElementsByTagName("*")[0];
			if(child) { ((firstChild && (firstChild.tagName.toLowerCase() == "tbody")) ? firstChild : element).appendChild(child) }
		},
		parse: function(str){
			if(typeof(str)=="string"){
				if(document.createRange){
					var range = document.createRange();
					range.selectNode(document.body);
					var fragment = range.createContextualFragment(str);
					range.detach()
					return fragment;
				}else{
					var fragment = document.createElement("div");
					if(str.match(/^\s*?<tbody/)){
						fragment.innerHTML = '<table>' + str + '</table>';
						return fragment.childNodes[0].childNodes[0];
					}else if(str.match(/^\s*?<tr/)){
						fragment.innerHTML = '<table><tbody>' + str + '</tbody></table>';
						return fragment.childNodes[0].childNodes[0].childNodes[0];
					}else{
						fragment.innerHTML = str;
						return fragment;
					}
				}
			}
			return null
		}
	},
	str: {
		chars: function(c,n){
			var s = ""
			for(var i=0; i<n; i++){ s+=c }
			return s;
		},
		tab: function(n){
			return this.chars("\t",n)
		}
	},
	JSON: {
		decode: function(json){
			try{
				return eval("(" + json.replace(/(\/\*JSON | JSON\*\/)/g, "") + ")");
			}catch(e){
				new StixyError(e, json);
			}
		},
		replaceHTML: function(result){
		  if(result){
		    result.replace.eachProperty(function(name,value){
    		  Stixy.html.replace(name,value)
  			});
		  }
		},
		executeScript: function(result){
		  if(result){
  			eval(result.script || result);
		  }
		}
	},
	XML: {
		removeCDATASection: function(body){
  		if(!body.substr) { return body }
  		var replaced = body.replace(/<!\[CDATA\[/g,"")
			replaced = replaced.replace(/\[CDATA\[/g,"")
			replaced = replaced.replace(/\]\]>/g,"")
			return replaced.replace(/\]\]/g,"")
		},
		fromObject: function(o,s,formated){
			var s = s||"";
			function character(index,character){
				str = ""
				if(!formated) return str
				for(var x=0; x<index; x++){
					str += character;
				}
				return str
			}
			function g(o, i){
				o.eachProperty(function(n,v){
					s += character(i,"  ") + "<"+n+">"+character(1,"\n");
					if(typeof v == "object"){
						g(v, ++i);
					}else{
						s += character(i,"  ") + ("<![CDATA[" + ((typeof v == "function") ? v() : v) + "]]>"+character(1,"\n"));
					}
					s += character(i,"  ") + "</"+n+">"+character(1,"\n");
				})
				return s;
			}
			return g(o, 0);
		}			
	}
});

Stixy.extend(Stixy, {
	board: {
		id: null,
		inProgress: false,
		getID: function(){
			return this.id;
		},
		not_authorized: function (){
			if(Stixy.session.isAuthorized() || !Stixy.server.ques || (Stixy.server.ques.storage.length == 0)) return false;
			Stixy.popup.open("/public/new_stixyboard?popup=true");
			return true;
		},
		navigate: function(id, token, save_changes){
			this.announce("beforenavigate", {from:Stixy.board.id,to:id})
			this.announce("unload")
			this.listen("afterupdate", (function(oid){
				this.announce("afternavigate", {from:oid,to:id})
			}.b(this))(Stixy.board.id));
			if(this.inProgress){ 
				Stixy.board.resetBoardListItemState();
				Stixy.server.abort(); 
			}
			if(this.not_authorized()){ 
				this.storedNavigation = arguments;
				return;
			}
			this.inProgress = true;
			if(save_changes!==false){
				Stixy.server.update(function(request){
					Stixy.widgets.removeAll();
    			this.succeded(request);
					Stixy.board.updateBoardList(id);
				});
			}else{
				Stixy.server.reset();
			}
			this.setBoardListItemState(id);
			this.new_stixyboard = (!id);
			this.update(((token) ? '/invitation/join_ajax?token=' + token : '/public/index/' + id))
			if(token){ Stixy.board.updateBoardListItem(id) }
		},
		setBoardListItemState: function(id){
			Stixy.element.addClassName(Stixy.ui.base, "loading");
			this.old_item = Stixy.element.$ID("board_list_style_"+Stixy.board.id);
			this.new_item = Stixy.element.$ID("board_list_style_"+id);
			if(this.old_item) Stixy.element.removeClassName(this.old_item, "board-list-current");
			if(this.new_item){
				Stixy.element.addClassName(this.new_item, "board-list-current");
				Stixy.element.addClassName(this.new_item, "board-list-loading");
			}
		},
		resetBoardListItemState: function(id){
			Stixy.element.removeClassName(Stixy.ui.base, "loading");
			if(this.new_item){
				Stixy.element.removeClassName(this.new_item, "board-list-current");
				Stixy.element.removeClassName(this.new_item, "board-list-loading");
			}
		},
		update: function(url, new_stixyboard){
			Stixy.element.addClassName(Stixy.ui.base, "loading");
			var fade = new Stixy.effects.FadeOut(Stixy.ui.canvas_content, 0.3, 0.3)
			Stixy.server.connect(null, url, function(request){
			  fade.cancel();
			  var result = Stixy.JSON.decode(request.responseText);
				var transitNode = Stixy.ui.canvas_content.cloneNode(true);
				transitNode.id = ''
				Stixy.ui.canvas_content.parentNode.appendChild(transitNode);
				Stixy.element.setOpacity(Stixy.ui.canvas_content,0.3);
				Stixy.widgets.removeAll();
    		Stixy.JSON.replaceHTML(result);
				Stixy.ui.notification.reset();
  			Stixy.JSON.executeScript(result);
  			Stixy.ui.listen('scrolltoposition', function(){
  			  new Stixy.effects.FadeIn(Stixy.ui.canvas_content, 0.2, 1)
  			  Stixy.element.removeClassName(Stixy.ui.base, "loading");
  			  if(this.new_item) Stixy.element.removeClassName(this.new_item, "board-list-loading");
  			  if(this.new_stixyboard) Stixy.board.updateBoardList();
  			  this.inProgress = false;
  			  this.announce("afterupdate");
    		}.b(this));
    		Stixy.ui.scrollToPosition(Stixy.ui.scrollPositions, true);
       	new Stixy.effects.Transition(transitNode, Stixy.ui.canvas_content, 0.5, function(){
  			  transitNode.parentNode.removeChild(transitNode)
				}.b(this));
			}.b(this));
		},
		updateBoardListItem: 	function(id){ Stixy.server.replace(null, "/board/board_list_compact_item_ajax/" + (id||Stixy.board.id), "board_list_item_" + (id||Stixy.board.id)) }, 
		addBoardFilter: 			function(set){ 
			this.boardsBeforeNav();
			Stixy.server.replace(null, encodeURI("/board/board_list_compact_ajax/" + Stixy.board.id + "?set_filters=true&filters=" + (set==0 ? "": Stixy.ui.tagFilter.getContent())), Stixy.ui.board_list_bar, Stixy.ui.tagFilter.reset.b(Stixy.ui.tagFilter));
		},
		sendNotification: function(){ 
			Stixy.element.$ID("board_notification_send").style.display = "none";
			Stixy.element.$ID("board_notification_sendig").style.display = "inline";
			Stixy.server.replace(Stixy.XML.fromObject({message:Stixy.ui.notification.getContent()}), encodeURI("/board/send_notification/" + Stixy.board.id), Stixy.element.$ID("board_notification"), Stixy.ui.notification.reset.b(Stixy.ui.notification), function(){
				Stixy.element.$ID("board_notification_send").style.display = "block";
				Stixy.element.$ID("board_notification_sendig").style.display = "none";
				alert("We're sorry.\n\nThe notification could not be sent due to unspecified reason. Please try again.");
			});
		},
		updateBoardList: function(id,params){	this.boardsBeforeNav(); Stixy.server.replace(null, "/board/board_list_compact_ajax/" + (id||Stixy.board.id) + (params ? "?" + params : ""), Stixy.ui.board_list_bar, 
			function(){
				Stixy.ui.tagFilter.reset.b(Stixy.ui.tagFilter)();
				Stixy.ui.initAllBoardListItems.b(Stixy.ui)();
			}) 
		},
		updateBoardOptions: 	function(parameters){ Stixy.server.replace(null, "/board/board_option_ajax/" + Stixy.board.id + (parameters ? "?" + parameters : ""), Stixy.ui.bopt_bar, 
			function(){
				Stixy.ui.notification.reset.b(Stixy.ui.notification)();
			}) 
		},
		updateUtilityNav: 		function(){	Stixy.server.replace(null, "/utility_navigation_ajax", 'utility_navigation') },
		openInvite: 					function(){ Stixy.popup.open("/board/invite/" + Stixy.board.id + "?popup=true" ,null,null,Stixy.board.updateBoardOptions) },
		openSetting: 					function(){	Stixy.popup.open("/setting/index?popup=true",null,null) },
		openOverview: 				function(){	Stixy.popup.open("/board/board_list_detailed?popup=true",10000,10000) },
		openCalendar: 				function(){	Stixy.popup.open("/calendar?popup=true",10000,10000) },
		boardsBeforeNav: 			function(){ Stixy.element.addClassName(Stixy.element.$ID("board_list_scroll"),"board-loading") },
		openSignin: function(){	
			Stixy.popup.open("/signin?popup=true",null,null) 
		},
		openOption: function(){	
			Stixy.popup.open("/board/option/" + Stixy.board.id + "?popup=true",null,null) 
		},
		openTrashCan: function(){	
			Stixy.popup.open("/board/trash_can/" + Stixy.board.id + "?popup=true",null,null) 
		},
		openSignup: function(){	
			Stixy.popup.open("/signup?popup=true",null,null) 
		},
		newStixyboard: function(){
			if(this.not_authorized()){
				this.storedNavigation = arguments;
				return;
			};
			Stixy.board.navigate(0);
		},
		reset: function(){
			Stixy.server.reset();
			Stixy.popup.close();
		},
		cancelAndContinue: function(){
			Stixy.board.reset();
			if(Stixy.board.storedNavigation) Stixy.board.navigate.apply(Stixy.board, Stixy.board.storedNavigation);
		},
		updateAll: function(board_options_state,board_list_state,widget_tray_state,fetch_latest){
			Stixy.board.updateUtilityNav();
			Stixy.board.updateBoardList();
			Stixy.board.navigate(fetch_latest ? "" : Stixy.board.id);
			Stixy.ui.boptToggle(null,board_options_state,false);
			Stixy.ui.boardListToggle(null,board_list_state,false);
			Stixy.ui.trayToggle(null,widget_tray_state,false);
		},
		navigatePopup: function(e, url){
			Stixy.events.stop(e);
			window.location.href = url + ((/\?/.test(url)) ? "&" : "?") + "popup=true&from_popup=true";
		}
	}
});

Stixy.extend(Stixy, {
	flash: {
		pending: [],
		add: function(src,target,name,options){
			var ref = {source:null};
			this.pending.push({src:src,target:target,name:name,options:options,ref:ref});
			return ref;
		},
		loaded: (function(){
			Stixy.listen("ready", function(){
				try{
					for(var i=0; i<Stixy.flash.pending.length; i++){
						var pending = Stixy.flash.pending[i];
						var options = pending.options||{}
						var element = (Stixy.flash.activeX) ? document.createElement("object") : document.createElement("embed");
						var attr = { width:(options.width||1), height:(options.height||1), id:pending.name }
						var params = { menu:"false", wmode:"transparent", quality:"high", bgcolor:"#000000", src:pending.src}
						if(Stixy.flash.activeX){
							Stixy.extend(params,{
								_cx:"5080", _cy:"5080", flashVars:"", movie:pending.src, play:"0", loop:"-1", sAlign:"", base:"",
								allowScriptAccess:"", scale:"ShowAll", deviceFont:"0", embedMovie:"0", swRemote:"", movieData:"",
								seamlessTabbing:"1", profile:"0", profileAddress:"", profilePort:"0"
							})
						}
						options.eachProperty(function(name,value){
							if(name!="height"&&name!="width"){
								params[name] = value;
							}
						})
						if(Stixy.flash.activeX){
							attr.classid = "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000";
							attr.eachProperty(function(name,value){
								element.setAttribute(name,value);
							})
							params.eachProperty(function(name,value){
								var p = document.createElement("param")
								p.setAttribute("name", name);
								p.setAttribute("value", value);
								element.appendChild(p);
							})
						}else{
							params.type = "application/x-shockwave-flash" 
							Stixy.extend(attr,params)
							attr.eachProperty(function(name,value){
								element.setAttribute(name,value);
							})
						}
						var t = (pending.target) ? Stixy.element.$ID(pending.target) : document.body.appendChild(function(){
							var d = document.createElement("div");
							d.setAttribute("style", "position:absolute;");
							return d;
						}());
						if(Stixy.flash.activeX){
							t.innerHTML = element.outerHTML;
							pending.ref.source = t.children[0];
						}else{
							pending.ref.source = t.appendChild(element);
						}
					}
					Stixy.flash.loaded = true;
				}catch(e){ }
			});
			return false;
		})(),
		activeX: (function(){
			return (navigator.plugins&&navigator.mimeTypes.length) ? false:true;
		})(),
		version: false,
		isCompatible: function(min,max){
			this.version = this.version || (function(){
				if(this.activeX){
					try{
						var a = new ActiveXObject("ShockwaveFlash.ShockwaveFlash"), v = 0;
						for(var i=3; a!=null; i++){
							a = new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+i);
							v = i;
						}
					}catch(e){}
					return v;
				}else{
					var p = navigator.plugins["Shockwave Flash"];
					if(p&&p.description){ return p.description.replace(/([a-z]|[A-Z]|\s)+/,"").replace(/(\s+r|\s+b[0-9]+)/,".").split(".")[0] }
				}
			}.b(this))()
			var max = max||this.version;
			return (this.version>=min&&this.version<=max)
		}
	}
});

Stixy.extend(Stixy, {
	features: {
		Base: function(widget, attributes){
		  this.widget = widget;
			this.attachedEvents = [];
		  this.target = attributes["target"] || attributes["source"] || null;
		  this.source = attributes["source"] || attributes["target"] || null;
			this.observe = function(target, eventName, func, phase){
				phase = phase||false
				this.attachedEvents.push([target, eventName, func, phase]);
				Stixy.events.observe(target, eventName, func, phase);
			}
			this.stopObserving = function(target, eventName, func, phase){
				phase = phase||false
				for(var i=0; i<this.attachedEvents.length; i++){
					var ev = this.attachedEvents[i];
					if(ev[0]==target && ev[1]==eventName && ev[2]==func && ev[3]==phase) { this.attachedEvents.splice(i,1) }
				}
				Stixy.events.stopObserving(target, eventName, func, phase);
			}
			this.remove = function(test){
				for(var i=0; i<this.attachedEvents.length; i++){
					var ev = this.attachedEvents[i];
					Stixy.events.stopObserving(ev[0], ev[1], ev[2], ev[3]);
					this.cashed_events = {};
				}
				delete this.events;
				this.events = [];
			}
			if(!this.target && !this.source) { return null }
		},
		common: {}
	}
});

Stixy.features.common.Size = function(){
	this.grid = 10;
	this.snap = false;
	this.snapToGrid = function(){
		if((!this.snap && (!Stixy.events.activeKeys[16]))||(this.snap && (Stixy.events.activeKeys[16]))) { return }
		this.x = Math.round(this.x/this.grid) * this.grid;
		this.y = Math.round(this.y/this.grid) * this.grid;
	}
}

// Always test when code is updated:
// Scroll stixyboard horizontal and vertical and move widgets and add new widgets

Stixy.features.Move = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
	this.offsetX = 0;
  this.offsetY = 0;
	this.left = this.target.offsetLeft;
  this.top = this.target.offsetTop;
	this.startX = 0;
	this.startY = 0;
	this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.start = attributes["start"]   || -100000;
  this.stop = attributes["stop"] || 100000;
  this.minX = attributes["minX"] || 100000;
  this.minY = attributes["minY"] || 100000;
  this.maxX = attributes["maxX"] || 100000;
  this.maxY = attributes["maxY"] || 100000;
  this.locked = this.stay = this.updated = this.inside = this.outside = false;
  this.droparea = attributes["droparea"] || null;
  this.setLock = function(lock){
    this.locked = lock || false;
  }
	this.setX = function(value){
		this.target.style.left = value + "px"
	}
  this.setY = function(value){
		this.target.style.top = value + "px"
	}
	this.reset = function(){
		this.setX(this.startX);
		this.setY(this.startY);
	}
	this.startMove = function(event){
		Stixy.events.stop(event);
    if(this.stay||this.locked||this.widget.locked) return;
		this.startX = this.target.offsetLeft;
		this.startY = this.target.offsetTop;
		this.offsetX = (event.clientX - this.startX);
    this.offsetY = (event.clientY - this.startY);
    this.announce("beforemove", event);
		this.observe(document, "mousemove",  this.move.be(this));
    this.observe(document, "mouseup",  this.stopMove.be(this));
  }
  this.move = function(event){
		if(this.locked) { return }
		this.announce("move");
    this.updated = true;
		Stixy.events.stop(event);
    if(this.droparea){
      if(event.clientX > this.droparea.left && event.clientX < this.droparea.right && event.clientY > this.droparea.top && event.clientY < this.droparea.bottom ){
				if(!this.inside) { this.announce("enterdroparea") }
				this.inside = true;
				this.announce("insidedroparea");
      }else{
				if(this.inside) { this.announce("leavedroparea") }
				this.inside = false;
				this.announce("outsidedroparea");
      }
    }
    this.x = event.clientX - this.offsetX;
    this.y = event.clientY - this.offsetY;
		this.snapToGrid();
    var pointer = [this.x,this.y];
    if(this.lastPointer && (this.lastPointer[0] == pointer[0] && this.lastPointer[1] == pointer[1])) { return }
    this.lastPointer = pointer;
		// Set the pointers so, for example, a widget can't be placed outside of a Stixyboard.
		pointer[0] = (((pointer[0]+this.minX)>0) ? pointer[0] : -this.minX);
		pointer[1] = (((pointer[1]+this.minY)>0) ? pointer[1] : -this.minY);
		if(this.horizontal && (pointer[0]>this.start) && (pointer[0]<this.stop)) { this.setX(pointer[0]) }
    if(this.vertical && (pointer[1]>this.start) && (pointer[1]<this.stop)) { this.setY(pointer[1]) }
  }
  this.stopMove = function(event){
    this.stopObserving(document, "mousemove",  this.move);
    this.stopObserving(document, "mouseup",  this.stopMove);
    this.announce("aftermove");
    this.updated = false;
  }
  this.observe(this.source, "mousedown",  this.startMove.be(this));
}
Stixy.features.Move.prototype = new Stixy.features.common.Size;

Stixy.features.Resize = function(widget, attributes){
  Stixy.features.Base.call(this, widget, attributes)
  this.proportional = attributes["proportional"] || false;
  this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.minWidth = attributes["minwidth"]   || 0;
  this.minHeight = attributes["minheight"] || 0;
  this.maxWidth = attributes["maxwidth"]   || 10000;
  this.maxHeight = attributes["maxheight"] || 10000;
  this.updated = false;
  this.originalAspectRatio = function(){
    this.originalWidth = this.target.scrollWidth;
    this.originalHeight = this.target.scrollHeight;
    this.aspectRatio = this.originalHeight / this.originalWidth;
  }
  this.startResize = function(event){
    if(this.widget.locked) return;
    this.announce("beforeresize");
    this.originalAspectRatio();
    this.offsetX = event.clientX;
    this.offsetY = event.clientY;
    this.observe(document, "mouseup",  this.stopResize.be(this));
    this.observe(document, "mousemove",  this.resize.be(this));
		try{
  		document.body.style.setProperty("-khtml-user-select","none","important");
		}catch(e){}
	}
  this.resize = function(event){
    Stixy.events.stop(event);
    this.updated = true;
    this.calculateSize(event.clientX, event.clientY);
		this.snapToGrid();
    this.updateSize()
    this.announce("resize");
  }
  this.stopResize = function(){
		this.stopObserving(document, "mouseup",  this.stopResize);
    this.stopObserving(document, "mousemove",  this.resize);
    this.announce("afterresize");
    this.updated = false;
  	try{
			document.body.style.removeProperty("-khtml-user-select");
		}catch(e){}
	}
  this.calculateSize = function(startX,startY){
    if(this.proportional) { var propertionalSize = ((startX - this.offsetX) +  (startY - this.offsetY)) / 2 }
    var newWidth =  (this.proportional) ? this.originalWidth + Math.round(propertionalSize / this.aspectRatio)
                                        : this.originalWidth + startX - this.offsetX;
    var newHeight = (this.proportional) ? this.originalHeight + Math.round(propertionalSize)
                                        : this.originalHeight + startY - this.offsetY;
    this.x = (newWidth  < this.minWidth)  ? this.minWidth  : (newWidth  > this.maxWidth)  ? this.maxWidth  : newWidth;
    this.y = (newHeight < this.minHeight) ? this.minHeight : (newHeight > this.maxHeight) ? this.maxHeight : newHeight;
  }
  this.updateSize = function(){
		if(this.horizontal) { this.target.style.width = this.x + "px" }
    if(this.vertical) { this.target.style.height = this.y + "px" }
  }
  this.updateAspectRatio = function(x,y){
		this.x = x;
		this.y = y;
		this.updateSize();
    this.widget.save({width:parseInt(this.widget.element.style.width),height:parseInt(this.widget.element.style.height)})
  }
  this.observe(this.source, "mousedown",  this.startResize.be(this));
}
Stixy.features.Resize.prototype = new Stixy.features.common.Size;

Stixy.features.Hover = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.mouseEnter = function(event){
    if(!Stixy.events.related(event, this.target)){
      this.announce("enter");
      this.announce("afterenter");
    }
  }
  this.mouseLeave = function(event){
    if(!Stixy.events.related(event, this.target)){
      this.announce("leave");
      this.announce("afterleave");
    }
  }
	this.observe(this.target, "mouseover", this.mouseEnter.be(this));
	this.observe(this.target, "mouseout", this.mouseLeave.be(this));
}

Stixy.features.Focus = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes);
	this.hasFocus = false;
	this.giveFocus = function(event){
		if(this.hasFocus && (event && event.shiftKey)){ 
			this.resetFocus() 
			return;
		}
		if(this.hasFocus) { return }
		if(!(event && event.shiftKey)){ this.global.announce("resetfocus") }
		this.global.listen("resetfocus", this.resetFocus.b(this));
		this.global.listen("singlefocus", this.singlefocus.b(this));
		this.hasFocus = true;
		this.global.multipleSelected(true);
		this.announce("gotfocus", this.global.areMultipleSelected());
		this.global.announce("newfocus", this.widget);
		this.observe(Stixy.ui.canvas, "mousedown", this.looseFocus.b(this), false);
	}
	this.singlefocus = function(){
		this.announce("singlefocus");
	}
	this.resetFocus = function(){
		if(this.hasFocus){
			this.deactivate();
    	this.delight();
    	this.stopFocus();
			this.global.multipleSelected(false);
		}
	}
	this.looseFocus = function(event){
		Stixy.events.stop(event);
		if(!Stixy.events.contained(event,this.widget.element) && !event.shiftKey){ 
			this.stopFocus() 
			this.global.resetMultipleSelect();
		}
	}
	this.stopFocus = function(){
		this.stopObserving(Stixy.ui.canvas, "mousedown", this.looseFocus.b(this), false);
		this.global.unlisten("resetfocus", this.resetFocus.b(this));
		this.global.unlisten("singlefocus", this.singlefocus.b(this));
		this.hasFocus = false;
		this.announce("lostfocus");
  }
  this.activate = function(event){
		this.isActive = true;
		this.announce("activated");
  }
	this.deactivate = function(event){
		if(this.isActive){
			this.isActive = false;
	    this.announce("deactivated");
	  }
	}
  this.highlight = function(event){
		this.observe(Stixy.ui.canvas, "mousedown", this.looseHighlight.b(this), true);
		this.global.resetHighlight();
		this.global.setWidget(this.widget);
		this.isHighlighted = true;
		this.announce("highlighted");
  }
	this.delight = function(event){
    if(this.isHighlighted){
			this.stopObserving(Stixy.ui.canvas, "mousedown", this.looseHighlight, true);
			this.isHighlighted = false;
	    this.announce("delighted");
  	}
	}
  this.looseHighlight = function(event){
		this.delight(event)
	}
	this.observe(this.source, "mousedown", this.giveFocus.b(this), true);
}
Stixy.features.Focus.prototype.global = new function(){
	this.multipleSelected = function(add){
		this.widgetCount += add ? 1 : -1;
		if(this.widgetCount==1){
			this.announce("singlefocus");
		}
	}
	this.areMultipleSelected = function(){
		return this.widgetCount > 1;
	}
  this.resetMultipleSelect = function(){
		this.widgetCount = 0;
	}
	this.resetMultipleSelect();
  this.resetHighlight = function(){
    if(this.widget){
      if(this.widget.focus.isActive) this.widget.focus.deactivate();
      if(this.widget.focus.isHighlighted) this.widget.focus.delight();
      this.resetWidget();
    }
  }
  this.setWidget = function(widget){
		this.widget = widget;
	}
  this.resetWidget = function(){
		this.widget = null;
	}
}

Stixy.features.Order = function (widget,attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.stay = (attributes["stay"]) ?  (attributes["stay"]==0) ? false : true : false;
  this.reset = attributes["reset"] || false;
  this.index = 0;
  this.changeOrder = function(order,force){
  	if((this.stay && !force)||this.widget.locked||(this.widget.focus&&this.widget.focus.global.areMultipleSelected())) { return }
    this.source.style.zIndex = (order===0) ? --this.global.bottom : ++this.global.top + this.widget.instances.length;
    this.id = (order===0) ? -(new Date().getTime()) : new Date().getTime();
    this.announce("shuffle");
  }
  this.autoMove = function(){
    this.stay = (this.stay) ? false:true;
  }
  this.observe(this.source, "mousedown", this.changeOrder.b(this), true);
}
Stixy.features.Order.prototype.global = new function(){
  this.top = 1000000;
  this.bottom = 1000000;
}

Stixy.features.Remove = function(widget,attributes){
  Stixy.features.Base.call(this, widget, attributes)
  
  this.remove = function(event){
    Stixy.events.stop(event); 
		if(this.widget.locked) return;
    this.announce("beforeremove");
		this.widget.destroy();
  }.b(this)
  this.observe(this.source, "mousedown", this.remove, true);
}


// # TODO
// Known bugs:
// Safari: If one creates a link and have only selected one character, the character is not replaced
// by the link label, but pushed to the right.

Stixy.features.Text = (function(){
  var Text = function(widget, attributes){
    Stixy.features.Base.call(this, widget, attributes)
  	this.updated = false;
    this.document = document;
  	this.nativeEditor = nativeEditor();
  	this.pendingOpen = false;
  	this.editableState = true;
  	if(this.nativeEditor){
  		this.editor = null;
  		this.editable = function(state){
  			this.editableState = state===false ? false : true;
  			this.source.contentEditable = this.editableState;
  		}
  	  try {
  			document.execCommand('enableInlineTableEditing', false, "false");
      	document.execCommand('enableObjectResizing', false, "false");
  		}catch(e) { }
  		this.update = function(){
  		if(this.updated==false){
  			this.announce("beforeedit");
        this.updated = true;
      }
  	  }.b(this);
  		if(document.attachEvent){
  			this.observe(this.source, "mousedown", function(){
  				if(widget.focus){ widget.focus.giveFocus() };
  				if(widget.order){ widget.order.changeOrder() };
  			}.b(this));
  			this.observe(this.source, "beforeeditfocus", function(){
  			  if(!this.hasFocus){
    			  this.hasFocus = true;
    				this.observe(document, "keyup", this.update);
    				this.selection = document.selection;
    				var eventMouseDown = function(){
    					this.announce("beforeedit");
    					this.announce("gotfocus");
    					this.stopObserving(document, "mouseup", eventMouseDown.b(this));
    				}
    				this.observe(document, "mouseup", eventMouseDown.b(this));
    			}
  			}.b(this));
  			this.observe(document, "selectionchange", function(){
  				this.announce("textselected");
  	    }.b(this));
  		  this.observe(this.source, "beforedeactivate", function(){
  			  this.stopObserving(document, "keyup", this.update);
  				if( !Stixy.element.contained(event.toElement,this.widget.optionbar.base) && 
  				    !Stixy.element.contained(event.toElement,Stixy.ui.wopt_show) &&
  				    !Stixy.element.contained(event.toElement,Stixy.ui.wopt_hide)
  				  ){	
  					this.announce("lostfocus");
  				}
  				this.hasFocus = false;
  			}.b(this));
  		}else{
        // =========================================================================
        // = # TODO: From old js file. This needs to be refactored in a better way =
        // =========================================================================
		    if(!activeElementInitiated){
          var initActiveElement = function(element){
            Stixy.events.observe(element, "focus", function(e){
              window.activeElement = Stixy.events.element(e);
            });
            Stixy.events.observe(element, "blur", function(e){
              if(window.activeElement == Stixy.events.element(e)){
                delete window.activeElement;
              }
            });
          }
          var options = this.widget.optionbar.panel.getElementsByTagName("*");
          var length = options.length;
          for(var i=0; i<length; i++){
            initActiveElement(options[i]);
          }
          Stixy.events.observe(document.body, "DOMNodeInserted", function(e){
            initActiveElement(Stixy.events.element(e));
          })
          activeElementInitiated = true;
  		  }
  			this.observe(this.source, "focus", function(e){
  			  var eventLostFocus = function(e){
  			    setTimeout(function(){ // allow the focus event to set the activeElement before the blur event
      				if(Stixy.element.contained(window.activeElement, this.widget.optionbar.panel)){ return }
  				    this.stopObserving(this.source, "blur", eventLostFocus);
    				  this.announce("lostfocus");
  				  }.b(this),100)
    			}
  				this.observe(this.source, "blur", eventLostFocus.b(this));
  				var eventOutsideClick = function(e){
  			    if(!Stixy.events.contained(e,this.source) && !Stixy.events.contained(e,this.widget.optionbar.panel)){
  				    this.stopObserving(document, "click", eventOutsideClick);
      				this.source.blur();
  				  }
  				}
    			this.observe(document, "click", eventOutsideClick.b(this));
  				var eventMouseDown = function(){
  					this.announce("beforeedit");    			
  					this.announce("gotfocus");
  					this.stopObserving(document, "mouseup", eventMouseDown.b(this));
  				}
  				this.observe(document, "mouseup", eventMouseDown.b(this));
  				this.observe(document, "keyup", this.update);
  				this.selection = window.getSelection();
  			}.b(this));
  		  
        // var sourceGotFocus = function(e){
        //   this.hasFocus = true;
        //          var eventOutsideClick = function(e){
        //            if( !Stixy.element.contained(Stixy.events.element(e), this.widget.optionbar.base) &&  
        //                !Stixy.element.contained(Stixy.events.element(e), this.source) && 
        //                !Stixy.element.contained(Stixy.events.element(e), Stixy.ui.wopt_show) &&
        //                !Stixy.element.contained(Stixy.events.element(e), Stixy.ui.wopt_hide)
        //              ){
        //              this.stopObserving(this.widget.element, "mousedown", eventOutsideClick);
        //              this.stopObserving(document, "mousedown", eventOutsideClick);
        //              this.source.blur();
        //            }else{
        //              Stixy.events.halt(e);
        //            }
        //          }
        //          this.observe(document, 'keydown', function(e){
        //            if(e.keyCode == 9 && this.hasFocus){
        //              eventOutsideClick();
        //            }
        //          }.b(this))
        //          this.observe(this.widget.element, "mousedown", eventOutsideClick.b(this));
        //          this.observe(document, "mousedown", eventOutsideClick.b(this));
        //  var eventMouseDown = function(){
        //    this.announce("beforeedit");          
        //    this.announce("gotfocus");
        //    this.stopObserving(document, "mouseup", eventMouseDown.b(this));
        //  }
        //  this.observe(document, "mouseup", eventMouseDown.b(this));
        //  this.observe(document, "keyup", this.update);
        //  this.selection = window.getSelection();
        //        }
        // this.observe(this.source, "focus", sourceGotFocus.b(this));
        //        this.observe(this.source, "blur", function(e){
        //  this.hasFocus = false;
        //   this.stopObserving(document, "mouseup", sourceGotFocus);
        //        }.b(this));
        // window.listen("textselected", function(source){
        //   if(Stixy.element.contained(source,this.source)){
        //            this.reformatMozBogusNode();
        //            this.announce("textselected");
        //   }
        // }.b(this));
        //        this.observe(this.source, "blur", function(event){
        //          this.stopObserving(document, "keyup", this.update);
        //  this.announce("lostfocus");
        // }.b(this));
  		}
    }else{
  		this.editable = function(state){
  			this.editableState = state===false ? false : true;
  			if(!this.editableState){
  				this.destroy();
  			}
  		}
  		this.editor.text = this;
  	  this.editor.widget = widget
  		this.eventCreate = function(){this.announce("gotfocus") }.b(this);
  		this.eventBeforemove = function(){ this.destroy() }.b(this);
  		this.eventBeforeresize = function(){ this.destroy() }.b(this);
  		this.eventBeforeedit = function(){this.announce("beforeedit") }.b(this);
  		this.eventLostfocus = function(){ this.destroy() }.b(this);
  		this.eventTextselected = function(){
  			this.selection = this.editor.selection;
  			this.announce("textselected");
      }.b(this);
  	}
    this.getSource = function(){
  		if(this.editor && (this.editor.widget==this.widget && this.editor.window)){
        this.editor.updated = false;
        var text = this.editor.body.innerHTML;
      }else{
  			this.updated = false;
        var text = this.source.innerHTML;
      }
  		return text.replace(/&(lt|gt);/g,"&__STIXYREMOVE__$1;")
    }
  	this.giveFocus = function(){
  		if(this.editor){
  			this.editor.window.contentWindow.focus();
  		}
  	}
  	this.waitToOpen = function(){
  		this.openEditor();
  	}
    this.openEditor = function(){
  		if(this.editor.initiating==true || !this.editableState) return
  		this.widget.move.listen("beforemove", this.eventBeforemove);
  		this.widget.resize.listen("beforeresize", this.eventBeforeresize);
  		this.widget.focus.listen("lostfocus", this.eventLostfocus);
  		this.editor.listen("create", this.eventCreate);
  		this.editor.listen("beforeedit", this.eventBeforeedit);
  		this.editor.listen("textselected", this.eventTextselected);
  		this.editor.open(this.source, this.widget);
    }
    this.destroy = function(){
  		if(this.editor && this.editor.initiating==true) return
  		this.widget.move.unlisten("beforemove", this.eventBeforemove);
  		this.widget.resize.unlisten("beforeresize", this.eventBeforeresize);
  		this.widget.focus.unlisten("lostfocus", this.eventLostfocus);
  		if(this.editor){
  			this.editor.unlisten("create", this.eventCreate);
  			this.editor.unlisten("beforeedit", this.eventBeforeedit);
  			this.editor.unlisten("textselected", this.eventTextselected);
  			this.editor.destroy();
  		}
  		this.announce("lostfocus");
    }
    this.catchMousedown = function(event){
      Stixy.events.halt(event);
  		if(this.editor){
  			this.editor.beforeEdit = this.beforeEdit;
  			this.observe(this.source, "mouseup",  this.openEditor.b(this));
      }
  	}
  	// To catch and cancel drag/resize and any other possible mousedown events
    this.observe(this.source, "mousedown", this.catchMousedown.be(this), true);
    // Link tooltip for the instance
    this.linkTooltip = new Text.LinkTooltip(this.widget.element);
    this.observe(this.source, "mouseover", function(e){
      this.linkTooltip.showUnless(e, this.widget);
    }.b(this));
    this.linkTooltip.listen("editclick", function(e,link,href,label){
      this.editLink(link,href,label)
    }.b(this));
    this.linkTooltip.listen("linkclick", function(e,link,href){
      Stixy.openExternalWindow(href);
    }.b(this));

  }
  
  // Text selection for Safari and Firefox. Comparable to IE "onselectionchange" native event.
	
  if(!document.attachEvent){
    this.handleTextSelect = function(e){
		  if(window.getSelection().rangeCount > 0){
    		var _tmp_select = window.getSelection().getRangeAt(0);
    		try{
    			if(!this._tmp_select_compare || this._tmp_select_compare.collapsed || (_tmp_select.compareBoundaryPoints(Range.START_TO_START,this._tmp_select_compare)!=0)||(_tmp_select.compareBoundaryPoints(Range.END_TO_END,this._tmp_select_compare)!=0)){
    				window.announce("textselected", Stixy.events.element(e));
    			}
    		}catch(e){ }
		    this._tmp_select_compare = _tmp_select
    	}
    }.b(this);
  	Stixy.events.observe(document, "mouseup",  this.handleTextSelect);
		Stixy.events.observe(document, "keyup",  this.handleTextSelect);
	}
  
  
// ===========
// = Methods =
// ===========  
  
  /*----------------------------------------
  
  Firefox 3 has a bug that disables execCommand to work as supposed. This happens when all content of a node with 
	contenteditable="true" is selected and the node is a child of another node (other than body). This is a patch that 
	adds an extra node outside of the selection. This enables the execCommand 
	to work, since all content of the node is no longer selected.
	
	Also, text can't be formated if the text node is the first node inside, text in that node can't be formated with execCommand
	http://fretlessjazz-ux.blogspot.com/2009/09/implementing-rich-text-editor-with.html
  ----------------------------------------*/
  var mozEditorBlockSpacerName = 'sx:moz-editor-block-spacer';
  
  var addMozBogusNode = function(source){
    if(Stixy.ua.gecko){
      if(!hasMozBogusNode(source)){
        var bogusNode = document.createElement(mozEditorBlockSpacerName);
        bogusNode.appendChild(document.createElement('div'));
        source.insertBefore(bogusNode, source.firstChild)
      }
      return bogusNode;
    }
  }
  
  var getAllMozBogusNodes = function(source){
    return source.getElementsByTagName(mozEditorBlockSpacerName);
  }
  
  var getMozBogusNode = function(source){
    return getAllMozBogusNodes(source).item(0);
  }
 
  var hasMozBogusNode = function(source){
    return getMozBogusNode(source) != null
  }
  
  var replaceMozBogusNode = function(source){
    var nodes = getAllMozBogusNodes(source);
    for(var i=0; i<nodes.length; i++)
      source.removeChild(nodes[i]);
    return addMozBogusNode(source);
  }

  var reformatMozBogusNode = function(){
    if(Stixy.ua.gecko){
      var selection = this.getSelection();
      if(selection.anchorNode == this.source && selection.anchorOffset == 0){
        var bogusNode = replaceMozBogusNode(this.source);
        var range = document.createRange();
        range.setStart(bogusNode.nextSibling,0);
        range.setEnd(selection.focusNode, selection.focusOffset);
        selection.removeAllRanges();
        selection.addRange(range);
      }
    }
  }
  
  // =================
  // = Range methods =
  // =================
  
  var getRange = function(){
    var selection = this.getSelection();
    return  selection.createRange ? selection.createRange() :
            selection.rangeCount  ? selection.getRangeAt(0) : document.createRange();
  }
  
  var selectionToRange = function(selection){
    var selection = selection || this.getSelection();
    var range = this.getRange();
    if(!selection.createRange){
      range.setStart(selection.anchorNode, selection.anchorOffset);
      range.setEnd(selection.focusNode, selection.focusOffset);
    }
    return range;
  }

  var rangeToSelection = function(range){
    if(range.select){
      range.select();
    }else{
      this.collapseSelection();
      this.getSelection().removeAllRanges();
      this.getSelection().addRange(range);
    }
  }
  
  // =====================
  // = Selection methods =
  // =====================
  
  var trimSelection = function(){
    var selection = this.getSelection();
    var range = this.getRange();
    if(range.text){
      // We only need to do this for IE, for now, since the W3 compatible selectWord method does the same
      var text = range.text;
      var offsetLeft = text.search(/\S(?!^\s)/);
      var offsetRight = text.search(/\s+$/);
      offsetRight -= (offsetRight >= 0) ? text.length : offsetRight;
      range.moveStart('character', offsetLeft);
      range.moveEnd('character', offsetRight);
      range.select();
    }
  }

  var getSelection = function(){
    return this.nativeEditor ? (document.selection || window.getSelection()) : this.editor.window ? this.editor.window.contentWindow.getSelection() : window.getSelection();
  }
  
  var getSelectionNodes = function(){
  	var anchorNode, anchorOffset, selection = this.getSelection();
    if(document.selection){
  		var range = selection.createRange();
      range.pasteHTML('<i id="_ie_bocus_cursor_position" style="position:absolute;width:0;overflow:hidden;">_ie_bocus_cursor_position</i>');
  	  var bogusNode = range.parentElement();
  		anchorNode = range.parentElement().parentElement;
  		anchorOffset = anchorNode.innerText.search(/_ie_bocus_cursor_position/);
  		anchorNode.removeChild(bogusNode);
  	}else{
  	  anchorNode = selection.anchorNode;
  		anchorOffset = selection.anchorOffset;
  	  focusNode = selection.focusNode;
  		focusOffset = selection.focusOffset;
  	}
  	return { anchorNode:anchorNode, anchorOffset:anchorOffset, focusNode:focusNode, focusOffset:focusOffset }
  }
  
  var collapseSelection = function(){
    var selection = this.getSelection();
    if(document.selection){
      // IE
      selection.empty();
    }else{
      try{
        selection.collapse(null,0);
      }catch(e){ 
        try{
          //selection.collapseToStart();
        }catch(e){ }
      }
    }

  }

  
  // ================
  // = Node methods =
  // ================
  
  // Find first matching node below or above in the document hieracy relative to the startNode
  // If no startNode, start with the top most node in the document
  var findNode = function(startNode, test, above){
    var startNode = startNode || document;
    var test = test || function(node){ return startNode != node };
    var sibling = above ? 'previousSibling' : 'nextSibling';
    var child = above ? 'lastChild' : 'firstChild';
    var traverse = function(node, up){ 
      // Never go down in child nodes if traversing up to parent, or the find direction is "above" and it is first run of travering
      var childNode = up ? null : node[child];
      var nextNode = childNode || node[sibling] || node.parentNode;
      var beforeEntrying = (nextNode==childNode);
      var beforeLeaving = (nextNode==node.parentNode);
      return (test(node, nextNode, beforeEntrying, beforeLeaving) || !node) ? node : traverse(nextNode, beforeLeaving); 
    }
    return traverse(startNode, above)
  }

  // Find first matching node below document hieracy relative to the startNode
  var findNodeBelow = function(startNode, test){
    return this.findNode(startNode, test, false);
  }

  // Find first matching node above document hieracy relative to the startNode
  var findNodeAbove = function(startNode, test){
    return this.findNode(startNode, test, true);
  }

  var findParentNode = function(node, test){
    var test = test || function(){ return true };
    while(node = node.parentNode)
      if(test(node, node.parentNode))
        return node;
    return null;
  }

  var findNodeInside = function(startNode, stopNode, test, above){
    var test = test || function(){ return true };
    var node = (startNode == stopNode) ? null : this.findParentNode(startNode, function(node, nextNode){
      return (node == stopNode) || test(node, nextNode);
    });
    return (node == stopNode) ? null : node;
  }

  var findSiblingNode = function(node, test, above){
    var test = test || function(){ return true };
    var sibling = above ? 'previousSibling' : 'nextSibling';
    while(node = node[sibling])
      if(test(node, node[sibling]))
        return node;
    return null;
  }
  
  var findSiblingNodeAt = function(node, index, test){
    var i=0;
    var test = test || function(){ return true };
    while(node = node.nextSibling){
      if(isTextNode(node)) continue;
      if(test(node, node.nextSibling, i++) && i==index)
        return node;
    }
    return null;
  }

  var findChildNode = function(startNode, test){
    var test = test || function(){ return true };
    var stopNode = startNode.parentNode
    var node = !startNode.firstChild ? null : this.findNode(startNode.firstChild, function(node, nextNode){
      return test(node, nextNode) || node.parentNode == stopNode;
    });
    return !node || node.parentNode==stopNode ? null : node;
  }

  var findTextNode = function(node, regExpOrFn, above){
    var test = regExpOrFn instanceof RegExp ? function(node){ return regExpOrFn.test(node.data) } : regExpOrFn || function(){ return true }
    return this.findNode(node, function(node, nextNode){
      return node.nodeName == "#text" && test(node, nextNode);
    }, above);
  }
  
  var nextNode = function(node, left){
    var sibling = node[left ? 'previousSibling' : 'nextSibling'];
    return (node.hasChildNodes && node.hasChildNodes()) ?
       this.nextNode(node[left ? 'firstChild' : 'lastChild'], left) :
       sibling ? this.nextNode(sibling, left) : node;  
  }
    
  var isTextNode = function(node){
    if(!node || !node.nodeName) return false;
    return node.nodeName == "#text";
  }
  
  var isElementNode = function(node){
    if(!node || !node.nodeName) return false;
    return isTextNode(node)===false;
  }
  
  var createElement = function(tagName, attributes){
    var element = document.createElement(tagName);
    (attributes || {}).eachProperty(function(attribute, value){
      element.setAttribute(attribute, value);
    });
    return element;
  }
  
  var insertAroundNode = function(newChild, refChild){
    refChild.parentNode.insertBefore(newChild, refChild);
    newChild.appendChild(refChild);
    return newChild;
  }
  
  
  // ================
  // = Text methods =
  // ================
  
  var getText = function(element){
    return element.textContent || element.innerText || '';
  }

  var selectElementText = function(element){
    var selection = this.getSelection();
    var range = document.createRange ? document.createRange() : selection.createRange();
    if(range.moveToElementText){
      range.expand('textedit');
      range.moveToElementText(element);
      range.select();
    }else{
      this.collapseSelection();
      range.selectNode(element);
      selection.addRange(range);
    }
    this.focus();
    return range;
  }

  var replaceText = function(text){
    var selection = this.getSelection();
    if(selection.createRange){
      var range = selection.createRange();
      range.pasteHTML(text);
      range.moveStart('character', -text.length);
      range.select();
    }else{
      var storeEditorValues = this.getEditorValues();
      var range = document.createRange();
      range.setStart(selection.anchorNode, selection.anchorOffset);
      range.setEnd(selection.focusNode, selection.focusOffset);
      range.deleteContents();
      var fragment = range.createContextualFragment('');
      var node = document.createTextNode(text);
      fragment.appendChild(node);
      range.insertNode(fragment);
      range.setStart(node, 0);
      range.setEnd(node, text.length);
      selection.removeAllRanges();
      selection.addRange(range);
      this.setEditorValues(storeEditorValues);
    }
    this.focus();
    return node;
  }
  
  var selectTextNode = function(node){
    var selection = this.getSelection();
    if(selection.createRange){
      var range = selection.createRange();
      range.text = text;
      range.moveStart('character', -text.length)
      range.select();
    }else{
      var range = document.createRange();
      range.selectNode(node);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    this.focus();
    return range;
  }

  var selectWord = function(){
    if(document.selection){
      // # TODO: Fix word selection for IE. For now, trim white spaces of any selection.
      this.trimSelection();
      return;
    }
    var selection = this.getSelection();
    try{
    	var editor = this.source;
      var selectionNodes = this.getSelectionNodes();
      var blockElement = function(node){
        if(!node) return false;
        displayProperty = (node.style) ? node.currentStyle ? node.currentStyle.display : document.defaultView.getComputedStyle(node,false).getPropertyValue('display') : null;
      	return (displayProperty && !(/inline/.test(displayProperty))) || (node.tagName == 'BR' );
      }
      var getTextNode = function(above){
        function test(node, nextNode, beforeEntrying, beforeLeaving){
          return  blockElement(nextNode) || 
                  (isTextNode(node) && (/\s(?:\S)|(?:\S)\s/.test(node.data)) ||
                  (isTextNode(nextNode) && (above ? /\s$/ : /^\s/).test(nextNode.data)))
        }
        return this.findNode(selectionNodes.anchorNode, test, above);
      }
      var sameAnchorNode, anchorData, anchorOffset = 0;
      var sameFocusNode, focusData, focusPadding, focusOffset = 0;
      var anchorNode = getTextNode.b(this)(true);
      var focusNode = getTextNode.b(this)(false);

      if(!isTextNode(anchorNode)){
        anchorNode = this.findTextNode(anchorNode);
      }
      sameAnchorNode = anchorNode == selectionNodes.anchorNode;
      anchorData =  !sameAnchorNode ? anchorNode.data : anchorNode.data.substr(0,selectionNodes.anchorOffset);
      anchorOffset = anchorData.search(/\s(?!.*\s)/) + 1;

      if(!isTextNode(focusNode)){
        this.findChildNode(focusNode, function(node){
          focusNode = isTextNode(node) ? node : focusNode;
          return false;
        });
      }
      if(isTextNode(focusNode)){
        sameFocusNode = focusNode == selectionNodes.focusNode;
        focusData = !sameFocusNode ? focusNode.data : focusNode.data.substr(selectionNodes.focusOffset);
        focusPadding = sameFocusNode ? selectionNodes.focusOffset : 0;
        focusOffset = focusData.search(/\s/);
        focusOffset = (focusOffset < 0 ? focusData.length : focusOffset) + focusPadding;
      }

      // Extend to select word
      if(selection.getRangeAt){
        selection.removeAllRanges()
        var range = document.createRange();
        range.setStart(anchorNode, anchorOffset);
        range.setEnd(focusNode, focusOffset);
        selection.removeAllRanges();
        selection.addRange(range);
      }else{
      }
    }catch(e){ new StixyError(e, "015_feature_text.js line 607") }
  }
  
  // =====================
  // = Formating methods =
  // =====================
  
  var getEditorValues = function(){
    var range = this.selectionToRange();
    var selection = this.getSelection();
    // Select first character to query command against
    if(selection.anchorNode){
      var range = range.cloneRange();
      selection.anchorNode.parentNode.normalize()
      var selectionNode = this.findTextNode(selection.anchorNode);
      if(selectionNode && selection.extend){
        selection.collapse(selectionNode, 0);
        selection.extend(selectionNode, 1);
      }
    }else{
      var selectionRange = selection.createRange();
      var dupRange = range.duplicate();
      dupRange.collapse();
      dupRange.moveEnd('character', 1);
      dupRange.select();
    }
    
    var commandStates = ["justifycenter", "justifyfull", "justifyleft", "justifyright", "strikethrough", "bold", "italic", "subscript", "superscript", "underline"];
    var commandValues = ["fontsize", "forecolor", "hilitecolor", "fontname"];

    var storeEditorValues = {};
    function store(command,value){
      storeEditorValues[command] = value;
    }
    for(var i=0; i<commandStates.length; i++){
      var command = commandStates[i];
      try{
        store(command, document.queryCommandState(command))
      }catch(e){ continue }
    }
    for(var i=0; i<commandValues.length; i++){
      var command = commandValues[i];
      try{
        store(command, document.queryCommandValue(command));
      }catch(e){ continue }
    }
    if(!storeEditorValues.fontsize.length || /[^\d]+/.test(storeEditorValues.fontsize) && !Stixy.ua.ie){
      // Firefox does not always return font size for queryCommandValue, and Safari returns it in px size
      function stop(node){
        return (node.nodeType == 1 && node != this.source)
      }
      var node = this.findParentNode(selectionNode, stop);
      if(node == this.source){
        node = this.findParentNode(selection.focusNode, stop);
      }
      if(node){
        var fontSize = 2;
        var val = parseInt(document.defaultView.getComputedStyle(node, null).getPropertyValue("font-size"));
        var sizes = [10,13,16,18,24,32,48]
        for(var i=0; i<sizes.length; i++){
          if(val <= sizes[i]){
            fontSize=++i; 
            break;
          }
        }
        store('fontsize', fontSize)
      }
    }
    if(Stixy.ua.gecko || Stixy.ua.safari){ 
      //function find(node, tagName){
      //  return this.findNodeInside(node, this.source, function(node){
      //    return node.tagName == tagName;
      //  })
      //}
      //if(find.b(this)(selection.anchorNode, 'UL') || find.b(this)(selection.focusNode, 'UL')){
      //  store('insertunorderedlist', true)
      //}else if(find.b(this)(selection.anchorNode, 'OL') || find.b(this)(selection.focusNode, 'OL')){
      // store('insertorderedlist', true)
      //}
    }
    this.rangeToSelection(range);
    return storeEditorValues;
  }

  var setEditorValues = function(storeEditorValues){
    document.execCommand('removeformat', false, false);
    storeEditorValues.eachProperty(function(command,value){
      if(value !== false && value.length !== 0){
        try{
          document.execCommand(command, false, value);
        }catch(e){ }
      }
    })
    return true;
  }

  // Remove all tags except links
  var resetFormating = function(storeEditorValues){
    var links = this.source.getElementsByTagName('A');  
    var anchors = [];
    for(var i=0; i<links.length; i++){
      var link = links[i];
      var href = link.getAttribute('href');
      var text = this.getText(link);
      if(href && text.length > 0){
        link.innerHTML = "_STIXY_START_ANCHOR_" + i + "_" + text + "_STIXY_END_ANCHOR_";
        anchors.push({ index:i, href:href });
      }
    }
    var text = this.getText(this.source);
    text = text.replace(/_STIXY_END_ANCHOR_/gm, "</a>")
    while(anchors.length > 0){
      var anchor = anchors.shift();
      text = text.replace(new RegExp("_STIXY_START_ANCHOR_" + anchor.index + "_" , 'gm'), '<a href="' + anchor.href + '">')
    }
    this.source.innerHTML = text;
    addMozBogusNode(this.source);
  }
  
  // ================
  // = Misc methods =
  // ================
  
  var nativeEditor = function(){
    return document.body.contentEditable !== undefined;
  }
  
  var getDocument = function(){
    if(this.editor){
  		if(this.editor.window) { return this.editor.window.contentDocument }
  		return document;
    }else{
  		return document;
    }
  }

  var focus = function(){
    if(nativeEditor()){
  		var storedSelection = this.selectionToRange();
  		this.source.focus();
      this.rangeToSelection(storedSelection);
    	this.announce("beforeedit");
  		this.announce("gotfocus");
    }else{
      this.editor.setEditorFocus();
    }
  }

  var editLink = function(link, href, label){
    if(Stixy.ua.unless(/Firefox\/2/)){
      if(link && href){
        this.selectElementText(link);
        this.openEditLinkPopup(link, href, label)
      }    
    }
  }

  var validURL = function(link_value){
    if(!link_value || !link_value.match(/^(http\:\/\/|mailto\:\/\/|https\:\/\/|ftp\:\/\/|[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}|.*?@.+\.\w{2}/)){
      var error_value = link_value.match(/\w+/) ? '"'+link_value+'" is not recogized as a web address or an e-mail address. '  : '';
      alert(error_value + 'Please add a valid address in the "Link field" before pressing the "Insert link" button.')
      return false;
    }
    return true;
  }

  var openEditLinkPopup = function(link, value, label, callback){
    
    var selection = this.getSelection();
    //if(selection.isCollapsed){
    //  this.selectWord();
    //}
    this.trimSelection();
    // Use selected text if pattern match url format
    var selectedText = document.selection ? this.getSelection().createRange().text : this.getSelection().toString();
    if(!value && selectedText.search(/^(http\:\/\/|mailto\:\/\/|https\:\/\/|ftp\:\/\/|[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}|.*?@.+\.\w{2}/) != -1){
      // if a text that is probably a link is selected
      var predefinedValue = selectedText;
    }
    
    var edit = {
      replace: {"popup_content": "<h2 style=\"margin:10px 0 0;\">Insert link</h2>\n<p>\n<h4 style=\"margin-bottom:2px\">Link label</h4>\n<input type=\"text\" id=\"label\" style=\"width:310px;\" value=\"\" tabindex=\"1\">\n<p>\n<h4 style=\"margin-bottom:2px\">Web page or an e-mail address</h4>\n<input type=\"text\" id=\"link\" style=\"width:230px;\" value=\"\" tabindex=\"2\">\n<sx:button onmouseover=\"Stixy.events.stop(event)\" style=\"position:relative;top:-3px; left:8px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"navigate(); return false;\">Open</a></sx:t></sx:button>\n", "popup_buttons": "<sx:button onmouseover=\"Stixy.events.stop(event)\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"cancel(); return false;\">Cancel</a></sx:t></sx:button>\n\n\n<sx:button class=\"default\" onmouseover=\"Stixy.events.stop(event)\" style=\"margin-left:10px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"insertLink(); return false;\">Insert</a></sx:t></sx:button>\n"}
    }
    var insert = {
      replace: {"popup_content": "<h2 style=\"margin:10px 0 0;\">Edit or remove link</h2>\n<p>\n<h4 style=\"margin-bottom:2px\">Link label</h4>\n<input type=\"text\" id=\"label\" style=\"width:310px;\" value=\"\" tabindex=\"1\">\n<p>\n<h4 style=\"margin-bottom:2px\">Web page or an e-mail address</h4>\n<input type=\"text\" id=\"link\" style=\"width:230px;\" value=\"\" tabindex=\"2\">\n<sx:button onmouseover=\"Stixy.events.stop(event)\" style=\"position:relative;top:-3px; left:8px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"navigate(); return false;\">Open</a></sx:t></sx:button>\n", "popup_buttons": "<sx:button onmouseover=\"Stixy.events.stop(event)\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"cancel(); return false;\">Cancel</a></sx:t></sx:button>\n<sx:button onmouseover=\"Stixy.events.stop(event)\" style=\"margin-left:10px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"removeLink(); return false;\">Remove</a></sx:t></sx:button>\n<sx:button class=\"default\" onmouseover=\"Stixy.events.stop(event)\" style=\"margin-left:10px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"insertLink(); return false;\">Edit</a></sx:t></sx:button>\n\n"}
    }
    var json = !value ? edit : insert;

    // Populate fields in the popup
    if(predefinedValue || value){
      json.replace.popup_content = json.replace.popup_content.replace(/(id="link"[^<>]* value=")(.*?)(")/, '$1'+(value || predefinedValue)+'$3');
    }
    label =  label || (selection.createRange ? selection.createRange().text : selection.toString());
    if(label){
      json.replace.popup_content = json.replace.popup_content.replace(/(id="label"[^<>]* value=")(.*?)(")/, '$1'+label+'$3')
    }

    // Selection is lost when focus is moved to the input fields in the popup, 
    // so we need to store it and reset it once returned from the popup
    var storedSelection = this.selectionToRange();

    var cancelPopup = function(){
      this.focus() 
      this.rangeToSelection(storedSelection);
      Stixy.popup.unlisten('cancel', cancelPopup);
    }
    var showPopup = function(popupWindow){
      popupWindow.insertLink = function(e){
        Stixy.popup.unlisten('actionkey', popupWindow.insertLink);
        var link = popupWindow.Stixy.element.$ID("link");
        var label = popupWindow.Stixy.element.$ID("label");
        Stixy.popup.result = { link:link.value, label:label.value };
        Stixy.popup.done();
      };
      popupWindow.removeLink = function(){
        Stixy.popup.result = { remove:true };
        Stixy.popup.done();
      };
      popupWindow.navigate = function(url){
        var link = popupWindow.Stixy.element.$ID("link");
        var link_value = link.value;
        if(!link_value.match(/^.*?:\/\//)){
      		link_value = "http://"+link_value;
      	}
      	if(validURL(link_value)){
          popupWindow.Stixy.openExternalWindow(link_value);
      	}
      };
      popupWindow.cancel = function(){
        Stixy.popup.cancel();
      };
      setTimeout(function(){
        var link = popupWindow.Stixy.element.$ID("link");
        if(link){
          link.focus();
        }
      },100);
      if(!Stixy.ua.ie){
      // This needs to be fixed to work in IE. It seems like IE loses the focus when the return key is hit. We need to cancel the event first
        Stixy.popup.listen('actionkey', popupWindow.insertLink);
      }
    }

    Stixy.popup.listen('cancel', cancelPopup.b(this));
    Stixy.popup.listen('show', showPopup.b(this));

    Stixy.popup.populate(json, 370,225, function(){
      Stixy.popup.unlisten('cancel', cancelPopup);
      Stixy.popup.unlisten('show', showPopup);
      var remove_link = Stixy.popup.result.remove;
      var link_value = Stixy.popup.result.link || '';
      var link_label = Stixy.popup.result.label;
      (callback || new Function)();
      // Reset selection
      this.rangeToSelection(storedSelection);
      var selection = this.getSelection();
      if(remove_link){
        this.focus();
        document.execCommand("unlink", false, false);
      }else{
        // Validation
        if(!this.validURL(link_value)){
    		  this.focus();
          return;
    		}

        if(link_value.match(/.*?@.+\.\w{2}/)){
          if(!link_value.match(/^.*?:\/\//)){
            link_value = "mailto://"+link_value;
          }
        }else if(!link_value.match(/^.*?:\/\//)){
    			link_value = "http://"+link_value;
    		}
        link_label = link_label || link_value;
        var node = this.replaceText(link_label);
        if(Stixy.ua.gecko){
          var link = insertAroundNode(createElement('a', { href:link_value }), node)
          this.selectElementText(link);
        }else{
          document.execCommand('createlink', false, link_value);
        }
      }
      this.update();
    }.b(this))
  }

  // Link tooltip
  Text.LinkTooltip = function(source){
    this.source = source;
    this.visible = false;
    this.element = (function(){
      var container = document.createElement("div");
      var edit = document.createElement("div");
      container.innerHTML = '<sx:button class="tooltip button-icon"><sx:i></sx:i><sx:l><sx:p> </sx:p></sx:l><sx:r><sx:p></sx:p></sx:r><sx:t><span class="button-label">Edit link</span></sx:t></sx:button>'
      container.className = 'edior-link-tooltip';
      edit.className = 'edior-link-label';
      container.appendChild(edit);
      source.appendChild(container);
      this.edit = edit;
      // Click event breaks in IE. Something else is catching it.
      Stixy.events.observe(edit, "mousedown", this.editLink.b(this));
      Stixy.events.observe(container, "mousedown", this.navigateLink.b(this));
      return container;
    }.b(this))();
  }
  Stixy.extend(Text.LinkTooltip.prototype, {
    showUnless: function(e, widget){
      if(widget.locked) return;
      var element = Stixy.events.element(e);
      var link = (function(){
        function isAnAnchor(node){
          return (node.getAttribute && node.nodeName == "A" && node.getAttribute('href'));
        }
        return  isAnAnchor(element) ? element : widget.text.findNodeInside(element, widget.text.source, isAnAnchor);
      })()
      if(link){
        this.link = link;
        this.href = link.getAttribute('href');
        this.label = link.textContent || link.innerText;
        this.show(e, link, widget);
      }
    },
    show: function(e, element, widget){
      if(this.getState(element)) return;
      var hideEvent = function(e){
        var element = Stixy.events.element(e);
        if(!Stixy.element.contained(element, this.element) && element!=this.link && !Stixy.element.contained(element, this.link) ){
          Stixy.events.stopObserving(document, "mousemove", hideEvent);
          this.hide();
        }
      }.b(this);
      this.position(e, element, widget);
      this.element.style.display = 'block';
      this.setState(true, element);
  		Stixy.events.observe(this.link, "mousedown", this.navigateLink.b(this));
      Stixy.events.observe(document, "mousemove", hideEvent);
    },
  	hide: function(){
      this.element.style.display = 'none';
      this.setState(false, null);
      Stixy.events.stopObserving(this.link, "mousedown", this.navigateLink.b(this));
    },
    editLink: function(e){
      Stixy.events.stop(e);
      this.announce('editclick', e, this.link, this.href, this.label)
    },
    navigateLink: function(e){
      Stixy.events.stop(e);
      this.announce('linkclick', e, this.link, this.href)
    },
    position: function(e, element, widget){
      // Cursor offset
      var offsetX = e.clientX + Stixy.ui.canvas.scrollLeft - Stixy.element.positionedOffset(this.source, 'offsetLeft');
      var offsetY = e.clientY + Stixy.ui.canvas.scrollTop - Stixy.element.positionedOffset(this.source, 'offsetTop');

      // Cursor offset to element when registred by the event
      var regX = offsetX - Stixy.element.positionedOffset(element, 'offsetLeft', this.source);
      var regY = offsetY - Stixy.element.positionedOffset(element, 'offsetTop', this.source);

      // Alter position if the position is registered more than 5 px from top/left
      offsetX -= (regX > 5) ? 10 : 0 ;
      offsetY -= (regY > 5) ? 5 : -5 ;

      this.element.style.left = offsetX + "px";
      this.element.style.top  = offsetY + "px";
    },
    setState: function(state, element){
      this.visible = state;
      this.currentElement = element;
    },
    getState: function(element){
      return this.visible && this.currentElement && this.currentElement == element;
    }

  });

  var editor = new function(){
    this.storedSelection = null;
    this.updated = false;
  	this.initiating = false;
  	this.listen("create", function(){ this.initiating = false }.b(this))
  	this.listen("beforeopen", function(){ this.initiating = true }.b(this));
    var update, element;
    this.update = function(){
      if(this.updated==false){
  			this.announce("beforeedit");
        this.updated = true;
      }
    }
    this.updateSize = function(event){ }
    this.getSelection = function(){
      var selection = window.getSelection();
      var source = this.source
      function getNodeIndex(node){
        var index, indexlist = [];
        while(node && (node != source)){
          index = 0;
          while(node.previousSibling){
            index++;
            node = node.previousSibling;
          }
          indexlist.push(index);
          node = node.parentNode;
        }
        return indexlist
      }
  		this.storedSelection = {};
      this.storedSelection.startIndex  = (selection.anchorNode)   ? getNodeIndex(selection.anchorNode).reverse() : [this.source.childNodes.length-1];
      this.storedSelection.startOffset = (selection.anchorOffset) ? selection.anchorOffset : 0;
      this.storedSelection.lastIndex   = (selection.focusNode)    ? getNodeIndex(selection.focusNode).reverse() : [this.source.childNodes.length-1];
      this.storedSelection.lastOffset  = (selection.focusOffset)  ? selection.focusOffset : 0;
    }
    this.deleteSelection = function(event){
  		if((!event.ctrlKey) && (!event.altKey) && (!event.metaKey) && (!event.shiftKey)){
  			if(event.type=="keydown" && !this.selection.isCollapsed){
  				if(event.charCode>=0) { 
  					this.selection.deleteFromDocument() 
  					this.selection.collapse(this.selection.focusNode, this.selection.focusOffset)
  				}
  				this.window.contentWindow.removeEventListener("keydown",  this.eventDeleteSelection, true);
  			}else if(event.type=="press" && !this.selection.isCollapsed){
  				if(event.keyCode==0||event.keyCode==46||event.which==8){
  					if(event.keyCode==46||event.which==8){
  						event.preventDefault();
  						event.stopPropagation();
  					}
  					this.selection.deleteFromDocument();
  				}
  				this.selection.collapse(this.selection.focusNode,this.selection.focusOffset);
  				delete this.selection;
  				this.window.contentWindow.removeEventListener("keypress", this.eventDeleteSelection, true);
  			}else{
  				if(event.keyCode==46||event.which==8){
  					event.preventDefault();
  					event.stopPropagation();
  				}
  				delete this.selection;
  				this.window.contentWindow.removeEventListener("keydown",  this.eventDeleteSelection, true);
  				this.window.contentWindow.removeEventListener("keypress", this.eventDeleteSelection, true);
  			}
  		}
  	}
    this.setSelection = function(){
  		var textRange = document.createRange();
      this.selection = this.window.contentWindow.getSelection();
  		if(this.body.innerHTML == '<font size="3"></font>'){
        var breakTag = document.createElement("br");
  			var fontTag = this.body.getElementsByTagName("font")[0];
        var spacer = fontTag.appendChild(document.createTextNode("."));
        var breaker = fontTag.appendChild(breakTag);
        textRange.setStart(spacer,0);
        textRange.setEnd(spacer,0);
        this.selection.addRange(textRange);
        this.selection.collapseToEnd();
  			spacer.deleteData(0,1);
  		}else{
  			function getNodeFromIndex(indexlist, node){
  				if(!node) { return }
  				while(indexlist.length>0 && node){
  					node = node.childNodes[indexlist.shift()];
  				}
  				return node;
  			}
  			var start = getNodeFromIndex(this.storedSelection.startIndex, this.body);
  			var last = getNodeFromIndex(this.storedSelection.lastIndex, this.body);
  			if(!start || !last) { return }
  			textRange.setStart(start,this.storedSelection.startOffset);
  			// We need to add a range and then collapse it to get around a bug in Firefox that causes
  			// an error when trying to check a command state on an added range
  			this.selection.addRange(textRange);
  			this.selection.collapseToEnd();
  			if(!(start==last&&this.storedSelection.startOffset==this.storedSelection.lastOffset)){
  				this.selection.addRange(textRange);
  				this.selection.extend(last,this.storedSelection.lastOffset)
  			}
  			this.eventDeleteSelection = this.deleteSelection.b(this)
  			this.window.contentWindow.addEventListener("keypress",  this.eventDeleteSelection, true);
  			this.window.contentWindow.addEventListener("keydown",  this.eventDeleteSelection, true);
  			this.storedSelection = null;
      }
  		setTimeout(function(){
  			this.setEditorFocus()
  			this.announce("textselected");
  		}.b(this), 1);
    }
    this.styleEditContent = function(){
      var sourceStyle = document.defaultView.getComputedStyle(this.source,null);
      function propertyTest(name){
        switch(name){
          case "position"||"top"||"right"||"bottom"||"left"||"width"||"height"||"clear"||
               "float"||"max-height"||"max-width"||"min-height"||"min-width"||"z-index": return true;
          default: return false;
        }
      }
      for(var i=0; i<sourceStyle.length; i++){
        var propertyName = sourceStyle.item(i);
        var propertyValue = sourceStyle.getPropertyValue(propertyName, null);
        if(propertyTest(propertyName)) {
          this.window.style.setProperty(propertyName, propertyValue, null);
        } else {
          this.body.style.setProperty(propertyName, propertyValue, null);
  			}
      }
    }
    this.destroy = function(){
  		if(this.window){
  		  if(this.body){
  				this.populateSource();
  		    this.body.removeEventListener("mouseup",this.eventTextSelected , true);
  			}
  	    if(this.window.contentWindow) {
  				//this.window.contentWindow.removeEventListener("keyup", this.eventKeyUp, true)
  			}
  			this.source.parentNode.removeChild(this.window);
  		  this.window = null;
  			this.announce("destroy");
  		}
  	}
  	this.setEditorFocus = function(){
  		if(this.window && (this.window.contentWindow)) { this.window.contentWindow.focus() }
  	}
    this.populateSource = function(){
  		while(this.body.hasChildNodes()) {
      	this.source.appendChild(this.body.firstChild);
  		}
      this.window.className = "editor-window-init";
      this.source.style.display = "block";
    }
    this.populateEditor = function(){
      if(this.window){
  			this.announce("beforepopulateeditor")
  	    this.body.innerHTML = ""
        while(this.source.hasChildNodes()) {
        	this.body.appendChild(this.source.firstChild);
  			}
        if(this.body.firstChild){
          if(this.body.firstChild.nodeType==1 && this.body.firstChild.getAttribute("_moz_editor_bogus_node")){
            this.body.removeChild(this.body.firstChild);
          }
        }
        this.source.style.display = "none";
        this.body.className = "editor-document";
        this.window.className = "editor-window";
  			this.setSelection();
        this.selection = this.window.contentWindow.getSelection();
      }
    }
    this.create = function(){
      this.window = document.createElement("iframe");
      this.window.className = "editor-window-init";
      if(this.source.nextSibling){
        this.source.parentNode.insertBefore(this.window, this.source.nextSibling);
      }else{
        this.source.parentNode.appendChild(this.window);
      }
      with(this.window.contentDocument){
        designMode = "on";
  			execCommand('enableInlineTableEditing', false, "false");
  	    execCommand('enableObjectResizing', false, "false");
  			execCommand("styleWithCSS", false, null);
  			// It's needed to open, write, and close the document to make it all work. 
  			// The . (period) needs to be erased before the real content is added to the body.
        open();
  			write(".")
        close();
      }
  		var style = this.window.contentDocument.firstChild.firstChild.appendChild(document.createElement("style"))
  		var s = parent.document.styleSheets;
  		var sl = s.length;
  		try{
  			for(var i=0; i<sl; i++){
  				var r = document.styleSheets[i].cssRules;
  				var rl = r.length;
  				for(var x=0; x<rl; x++){
  					this.window.contentDocument.styleSheets[0].insertRule(r[x].cssText.replace(/(^|\s|\})sx:/g,"$1sx\\:"),null)
  				}
  			}
  		}catch(e){ }
      this.body = this.window.contentDocument.firstChild.lastChild;
  		this.eventTextSelected = function(){
  			this.selection = this.window.contentWindow.getSelection();
  			this.announce("textselected");
      }.b(this);
      this.body.addEventListener("mouseup",this.eventTextSelected , true);
    }
  	this.eventKeyUp = this.update.b(this);
    this.init = function(){
      this.announce("beforecreate");
  		this.create();
  		this.styleEditContent();
  		this.source.style.display = "none";
      setTimeout(function(){
  			this.populateEditor();
  			this.announce("create");
  		}.b(this), 10);
  		update = this.eventKeyUp
  		element = this.window.contentWindow;
      this.window.contentWindow.addEventListener("keyup", this.eventKeyUp, true);
    }
    this.open = function(source, widget){
      this.announce("beforeopen");
  		if(this.window) {
        this.destroy();
  		}
      this.source = source;
      this.widget = widget;
  		this.getSelection();
      this.updated = false;
  		this.init();
    }
  }
  
  var activeElementInitiated;
  
  // Public instance methods
  Stixy.extend(Text.prototype, {
    reformatMozBogusNode  : reformatMozBogusNode,
    getRange              : getRange            ,
    getDocument           : getDocument         ,
    trimSelection         : trimSelection       ,
    selectionToRange      : selectionToRange    ,
    rangeToSelection      : rangeToSelection    ,
    getSelection          : getSelection        ,
    focus                 : focus               ,
    findNode              : findNode            ,
    findNodeBelow         : findNodeBelow       ,
    findNodeAbove         : findNodeAbove       ,
    findParentNode        : findParentNode      ,
    findNodeInside        : findNodeInside      ,
    findSiblingNode       : findSiblingNode     ,
    findSiblingNodeAt     : findSiblingNodeAt   ,
    findChildNode         : findChildNode       ,
    findTextNode          : findTextNode        ,
    isTextNode            : isTextNode          ,
    isElementNode         : isElementNode       ,
    getEditorValues       : getEditorValues     ,
    setEditorValues       : setEditorValues     ,
    resetFormating        : resetFormating      ,
    getSelectionNodes     : getSelectionNodes   ,
    selectElementText     : selectElementText   ,
    selectTextNode        : selectTextNode      ,
    replaceText           : replaceText         ,
    getText               : getText             ,
    nextNode              : nextNode            ,
    selectWord            : selectWord          ,
    collapseSelection     : collapseSelection   ,
    editLink              : editLink            ,
    validURL              : validURL            ,
    openEditLinkPopup     : openEditLinkPopup   ,
    editor                : editor           
  });
  
  return Text;
})();

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

// Scroll
// This feature is special written for scroll of canvas. It probably has to be rewritten 
Stixy.features.Scroll = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.offsetX = 0;
  this.offsetY = 0;
	this.left = 0;
  this.top = 0;
  this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.startMove = function(event){
    this.announce("beforescroll", event);
    Stixy.events.stop(event);
		this.offsetX = event.clientX + this.target.scrollLeft;
    this.offsetY = event.clientY + this.target.scrollTop;
    Stixy.events.observe(document, "mousemove",  this.move.b(this));
    Stixy.events.observe(document, "mouseup",  this.stopMove.b(this));
  }
  this.move = function(event){
    this.announce("scroll");
    this.updated = true;
    Stixy.events.stop(event);
		this.x = event.clientX - this.offsetX;
    this.y = event.clientY - this.offsetY;
    var pointer = {x:this.x,y:this.y};
    if(this.lastPointer && (this.lastPointer.x == pointer.x && this.lastPointer.y == pointer.y)) return;
    this.lastPointer = pointer;
		this.target.scrollLeft = -pointer.x;
		this.target.scrollTop = -pointer.y;

  }
  this.stopMove = function(event){
    Stixy.events.stopObserving(document, "mousemove",  this.move.b(this));
    Stixy.events.stopObserving(document, "mouseup",  this.stopMove.b(this));
    this.announce("afterscroll");
    this.updated = false;
  }
  Stixy.events.observe(this.source, "mousedown",  this.startMove.b(this), true);
	return this;
}

Stixy.effects = (function(){
  // Random shake
  var Shake = function(x,d,f){
    return 2.0 * (Math.cos((f + (Math.PI/d)) * x) - Math.cos((f - (Math.PI/d)) * x ));
  }
        
  var Steps = function(start,stop,steps,filter){
    var items = [];
    var step = (stop-start) / steps;
    for(var i=0; i<steps; i++)
      items.push(start += (filter ? filter[i] : step));
    return items;
  }
  
  var Ease = {
    diff: function(n){
      var s = 0;
      for(var i=0; i<n; i++)
        s += Ease.sin(i, n);
      return s;
    },
    sin: function(f, a, b, d){ 
      var b = d-b 
      var s = function(x){
        return x - Math.sin(x*2*Math.PI) / (2*Math.PI);
      }
      if(a && f < a) return s(f/a);
      if(b && f > b) return 1 - s((f-b)/(d-b));
      return 1;
    }
  }
  
  var EaseInOut = function(start, stop, easein, easeout, duration){
    var steps = [];
    var step = (stop-start) / duration;
    var diff = duration/(duration-Ease.diff(easein)-Ease.diff(easeout));
    for(var i=1; i<=duration; i++)
      steps.push(step * Ease.sin(i, easein, easeout, duration+1) * diff);
    return steps;
  }
        
  var KeyFrame = function(index,tracks){
    this.index = index;
    this.tracks = tracks;
    this.easeIn = 0;
    this.easeOut = 0;
  }
  
  var Timeline = function(duration, fps){
    this.duration = duration || 1;
    this.fps = fps || 50; //((Stixy.ua.firefox && parseFloat(Stixy.ua.minor.join('.')) < 3.5) ? 25 : 50)
    this.totalDuration = this.duration * this.fps;
    this.keyFrames = {};
    this.keyIndexes = [];
    this.tracks = {};
    this.onFinished = function(){}
    this.onFrame = function(){}
    var timeouts = [];
    function id(i){ return 'key_' + i }
    this.setKeyFrame = function(key, tracks){
      this.ready = false;
      var keyFrame = new KeyFrame(key, tracks);
      this.keyIndexes.push(key);
      this.keyFrames[id(key)] = keyFrame;
      return keyFrame;
    }
    this.render = function(){
      if(this.ready) return true;
      var keyIndexes = this.keyIndexes.sort(), from, to;
      for(var i=0,x=1; i < keyIndexes.length-1; i++,x++){
        from = this.keyFrames[id(keyIndexes[i])];
        to = this.keyFrames[id(keyIndexes[x])];
        from.tracks.eachProperty(function(property,track){
          var filter = new EaseInOut(track, to.tracks[property], from.easeIn*this.fps, from.easeOut*this.fps, this.totalDuration)
          var sequence = new Steps(track, to.tracks[property], this.totalDuration, filter)
      	  this.tracks[property] = (this.tracks[property]||[]).concat(sequence);
        }.b(this));
      }
      this.ready = true;
    }
    this.start = function(){
      this.render();
      var keys = new Steps(0, this.duration*1000, this.totalDuration);
      for(var i=0, x=this.totalDuration-1; i<this.totalDuration; i++, x--){
        var timeout = setTimeout(function(index, finished){
          var frame = {};
          this.tracks.eachProperty(function(property, track){
            frame[property] = track[index]
          }.b(this));
          this.onFrame(frame, index)
          timeouts.shift();
          if(finished) this.onFinished();
        }.b(this, i, !x), keys[i])
        timeouts.push(timeout);
      }
    }
    this.cancel = function(){
      for(var i=0; i<timeouts.length; i++){
        clearTimeout(timeouts[i]);
      }
    }
  }
  
  var Fade = function(source, from, to, duration, done_callback){
    this.source = source;
    var timeline = new Timeline(duration);
	  timeline.setKeyFrame(0, { opacity:from });
	  timeline.setKeyFrame(duration, { opacity:to });
	  timeline.onFrame = function(frame){
	    Stixy.element.setOpacity(source, frame.opacity);
	  }
	  timeline.onFinished = function(frame){
	    if(done_callback) done_callback()
	  }
	  timeline.start();
    this.cancel = timeline.cancel;
  }

  var Appear = FadeIn = function(source, seconds, opacity, done_callback){
    this.source = source;
    var transition = new Fade(source, Stixy.element.getOpacity(source), (opacity||1), seconds, done_callback);
    this.cancel = transition.cancel;
  }

  var Disappear = FadeOut = function(source, seconds, opacity, done_callback){
    this.source = source;
    var transition = new Fade(source, Stixy.element.getOpacity(source), (opacity||0), seconds, done_callback);
    this.cancel = transition.cancel;
  }
  
  var Transition = function(from, to, seconds, done_callback){
	  var count = 0;
    var done = function(){
      if(++count > 1 && done_callback)  done_callback();
    }
    new Appear(to,seconds,Stixy.element.getOpacity(from),done);
    new Disappear(from,seconds,0,done);
  }
  
  return {
    Timeline: Timeline,
    Steps: Steps,
    EaseInOut: EaseInOut,
    Transition: Transition,
    Fade: Fade,
    FadeIn: FadeIn,
    FadeOut: FadeOut,
    Appear: Appear,
    Disappear: Disappear
  }
})()	


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
          clearInterval(frameTimer);
  	      fn();
  	    }
  	  }, 100);
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
      parent.appendChild(containor);
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
		
    this.prepare = function(currentFrame,width,height,returnFunction){
      this.currentFrame = currentFrame;
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
        //this.populatedFrame.contentWindow.Stixy.JSON.replaceHTML({ replace: { popup_content:'' }});
		    // Show the populated frame with the progress indicator on as a default screen
        // and close it ones the navigated frame has loaded
        this.progress();
  			this.show(); 
  			var frameLoad = function(){
  		    //Stixy.events.stopObserving(this.navigatedFrame, 'load', frameLoad);
    	    var closed = this.currentFrame==null;
  		    this.hide();
  		    this.currentFrame = this.navigatedFrame;
  		    // Unless the populateFrame has been closed (the load has been canceled)
  		    if(!closed){
  		      this.show();
  		    }
  		  }.b(this);
        //Stixy.events.observe(this.navigatedFrame, 'load', frameLoad);
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
	  	this.register();
      Stixy.events.observe(this.currentFrame.contentWindow.document,"keyup", manageReturnKey.b(this));
      this.announce('show', this.currentFrame.contentWindow)
		}
		
		this.hide = function(){
      if(!this.container || !this.currentFrame) { return false }
		  this.width = null;
			this.height = null;
			this.progress(false);
			var popup_content = this.currentFrame.contentWindow.Stixy.element.$ID('popup_conten');
			if(popup_content){
			  this.currentFrame.contentWindow.Stixy.html.replace(popup_content, '');
			}
      this.currentFrame.style.display = "none";
			Stixy.events.stopObserving(this.currentFrame.contentWindow.document,"keyup", manageReturnKey.b(this));
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
	  start: function(){
	  	if(!this.autoSave) { return }
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
			this.setState(1);
			this.start();
			this.requestBody = null;
			logger.error("There was a problem retrieving the XML data:\n" + this.request.statusText);
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
					if(this.ques.pending){
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
				for(var i=0; i<this.ques.pending.boards[boardId].length; i++){
					this.ques.pending.boards[boardId][i].announce("aftersave");
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

// UI			
Stixy.extend(Stixy, {			
	ui: {
		elements: [],
		//scrollPositions: { left:0, top:0 },
		registerElements: function(){
			this.base = document.body;
			this.opt_bar = Stixy.element.$ID("opt_bar");
			this.bopt_bar = Stixy.element.$ID("bopt");
			this.board_list_bar = Stixy.element.$ID("board_list_bar");
			this.bopt_show = Stixy.element.$ID("bopt_show");
			this.bopt_hide = Stixy.element.$ID("bopt_hide");
			this.wopt_show = Stixy.element.$ID("wopt_hide");
			this.wopt_hide = Stixy.element.$ID("wopt_show");
			this.wopt_auto_show = Stixy.element.$ID("wopt_auto_show");
			this.wopt_auto_show_checkbox = Stixy.element.$ID("wopt_auto_show_checkbox");
			this.wopt_auto_show_title = Stixy.element.$ID("wopt_auto_show_title");
			this.tray_show = Stixy.element.$ID("tray_show");
			this.tray_hide = Stixy.element.$ID("tray_hide");
			this.board_list_show = Stixy.element.$ID("board_list_hide");
			this.board_list_hide = Stixy.element.$ID("board_list_show");
			this.canvas = Stixy.element.$ID("stixyboard");
			this.canvas_content = Stixy.element.$ID("canvas_content");
			this.save_button = Stixy.element.$ID("save-state-button");
			this.initElements();
			this.announce('elementsregistred');
		},
		initElements: function(){
			this.registerClassToggle("click", this.bopt_show, this.boptClose.b(this));
			this.registerClassToggle("click", this.bopt_hide, this.boptOpen.b(this));
			this.registerClassToggle("click", this.wopt_hide, this.woptClose.b(this));
			this.registerClassToggle("click", this.wopt_show, this.woptOpen.b(this));
			this.registerClassToggle("click", this.tray_show, this.trayToggle.b(this));
			this.registerClassToggle("click", this.tray_hide, this.trayToggle.b(this));
			this.registerClassToggle("click", this.board_list_show, this.boardListToggle.b(this));
			this.registerClassToggle("click", this.board_list_hide, this.boardListToggle.b(this));
			this.registerClassToggle("click", this.board_list_hide, this.boardListToggle.b(this));
			this.initAllBoardListItems();
			try{
				this.tagFilter = new Stixy.ui.extendedTextField("no-filter","tag_filter");
				this.notification = new Stixy.ui.extendedTextField("no-data","board_notification_box");
				Stixy.events.observe(this.wopt_auto_show_checkbox,"click",this.woptAutoShowToggle.b(this));
			}catch(e){ }
			if(this.save_button){
				Stixy.events.observe(this.save_button,"click",function(){
					if(Stixy.session.isAuthorized()){
						Stixy.server.update();
					}else{
						Stixy.board.openSignin();
					}
				});
			}
			
		},
		initAllBoardListItems: function(){
			try{
				this.boardListItems = Stixy.element.$CN("board-list-item", this.board_list_bar);
				for(var i=0; i<=this.boardListItems.length; i++){
					this.initBoardListItem(this.boardListItems[i])
				}
			}catch(e){ }
		},
		initBoardListItem: function(item){
			try{
				var id = item.id.match(/\d+/)[0]
				Stixy.events.observe(item, "mouseover", function(element,id,event){
					if(!Stixy.events.related(event,element)){
						this.dragOverItem = element;
						Stixy.ui.announce("mouseoverBoardListItem", element, id);
					}
				}.b(this,item,id));
				Stixy.events.observe(item, "mouseout", function(element,id,event){
					if(!Stixy.events.related(event,element)){
						Stixy.ui.announce("mouseoutBoardListItem", element, id);
						this.dragOverItem = null;
					}
				}.b(this,item,id));
			}catch(e){ }
		},
		pending: function(state){
			Stixy.ui.base[state ? "setAttribute" : "removeAttribute"]("id", "pending")
		},
		storeScrollPositions: function(){
			Stixy.ui.scrollPositions.left = Stixy.ui.canvas.scrollLeft;
			Stixy.ui.scrollPositions.top = Stixy.ui.canvas.scrollTop;
		},
		hasScrolled: function(){
			return	Stixy.ui.canvas.scrollLeft != Stixy.ui.scrollPositions.left ||
							Stixy.ui.canvas.scrollTop != Stixy.ui.scrollPositions.top;
		},
		scrollToPosition: function(position, duration){
			if(!position) { return };
			function scroll(position){
			  if(position.left!==undefined) Stixy.ui.canvas.scrollLeft = position.left ;
  			if(position.top!==undefined) Stixy.ui.canvas.scrollTop = position.top;
			}
			if(duration){
			  // #FIX
			  var duration = Math.min(0.5, Math.max(Math.abs(Stixy.ui.canvas.scrollLeft-position.left), Math.abs(Stixy.ui.canvas.scrollTop-position.top))/100);
			  var animation = new Stixy.effects.Timeline(duration);
    	  var startFrame = animation.setKeyFrame(0, { left:Stixy.ui.canvas.scrollLeft, top:Stixy.ui.canvas.scrollTop });
    	  animation.setKeyFrame(duration, { left:position.left, top:position.top });
    	  startFrame.easeIn = duration*0.20;
    	  startFrame.easeOut = duration*0.20;
    	  animation.onFrame = function(frame){
    	    scroll({left:frame.left, top:frame.top })
    	  }
    	  animation.onFinished = function(frame){
    	    this.announce("scrolltoposition");
    	  }.b(this);
    	  animation.start();
			}else{
			  scroll(position);
			  this.announce("scrolltoposition");
  		}
		},
		saveScroll: function(){
			if(Stixy.ui.canvas && Stixy.ui.saveStates && Stixy.ui.hasScrolled()){
				Stixy.server.connect({attributes:{left:Stixy.ui.canvas.scrollLeft,top:Stixy.ui.canvas.scrollTop}},"/board/board_save_scroll/"+Stixy.board.id);
			}
		},
		registerClassToggle: function(type,source,action){
			if(!source || !action) { return }
			Stixy.events.observe(source,type,action);
			Stixy.events.observe(source,"mouseover",function(event){ Stixy.events.stop(event) });
			Stixy.events.observe(source,"mousedown",function(event){ Stixy.events.stop(event) });
		},
		boptOpen: function(event,save){
			Stixy.events.stop(event)
			if(!Stixy.element.hasClassName(this.base,"wopt-hide")){
				Stixy.element.addClassName(this.base,"wopt-hide");
			}
			Stixy.element.replaceClassName(this.opt_bar,"bopt-panel-closed","bopt-panel-open");
			Stixy.element.replaceClassName(this.base,"bopt-closed","bopt-open");
			Stixy.element.removeClassName(this.base,"bopt-hide");
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_options:1}) };
		},
		boptClose: function(event,save){
			Stixy.events.stop(event)
			Stixy.element.replaceClassName(this.opt_bar,"bopt-panel-open","bopt-panel-closed");
			Stixy.element.replaceClassName(this.base,"bopt-open","bopt-closed");
			Stixy.element.removeClassName(this.base,"wopt-hide");
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_options:0}) };
		},
		woptOpen: function(event){
			Stixy.events.stop(event)
			if(!Stixy.element.hasClassName(this.base,"bopt-hide")){
				Stixy.element.addClassName(this.base,"bopt-hide");
			}
			Stixy.element.removeClassName(this.base,"wopt-hide");
			Stixy.element.removeClassName(this.opt_bar,"wopt-panel-closed");
			Stixy.element.addClassName(this.opt_bar,"wopt-panel-open");
			Stixy.element.removeClassName(this.base,"wopt-closed");
			Stixy.element.addClassName(this.base,"wopt-open");			
		},
		woptClose: function(event){
			Stixy.events.stop(event);
			Stixy.element.removeClassName(this.base,"bopt-hide");
			Stixy.element.removeClassName(this.opt_bar,"wopt-panel-open");
			Stixy.element.addClassName(this.base,"wopt-closed");
			Stixy.element.removeClassName(this.base,"wopt-open");
			Stixy.element.addClassName(this.opt_bar,"wopt-panel-closed");
		},
		woptAutoShowToggle: function(event, state, save){
			Stixy.widgets.Optionbar.setAutoShow(this.wopt_auto_show_checkbox.checked);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_auto_show_wopt:this.wopt_auto_show_checkbox.checked ? 1:0}) };
		},
		boptToggle: function(event, state, save){
			Stixy.events.stop(event);
			if(state==1){ this.boptOpen(save) }
			else{ this.boptClose(save) }
		},
		trayToggle: function(event, state, save){
			Stixy.events.stop(event)
			var result = this.toggle(null,"tray-open","tray-closed",state);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_widget_tray:result}) };
		},
		boardListToggle: function(event, state, save){
			Stixy.events.stop(event)
			var result = this.toggle(null,"board-list-open","board-list-closed",state);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_list:result}) };
		},
		toggle: function(target,show,hide,state){
			var target = target || this.base;
			var open = Stixy.element.hasClassName(target, show);
			if(state==0 || state==undefined && open){
				Stixy.element.replaceClassName(target,show,hide);
			}else{
				Stixy.element.replaceClassName(target,hide,show);
			}
			return open ? 0:1;
		},
		savePref: function(save){
			if(Stixy.session.isAuthorized()) { Stixy.server.connect({attributes:save},"/board/board_user_update_ajax") }
		},
		extendedTextField: function(deactiveClassName,fieldID){
			this.fieldID = fieldID;
			this.deactiveClassName = deactiveClassName;
			this.source = null;
			this.getContent = function(){
				return this.isActive() ? this.source.value : "";
			}
			this.isActive = function(){
				return !Stixy.element.hasClassName(this.source,this.deactiveClassName);
			}
			this.isEmpty = function(){
				return (this.source.value.search(/\S.*/) == -1);
			}
			this.focus = function(){
				if(!this.isActive()){
					this.source.value = "";
				}
				Stixy.element.removeClassName(this.source,this.deactiveClassName)
			}
			this.blur = function(){
				if(this.isEmpty()){
					this.source.value = this.source.title;
					Stixy.element.addClassName(this.source,this.deactiveClassName)
				}
			}
			this.reset = function(){
				this.source = Stixy.element.$ID(this.fieldID);
				if(this.source){
					Stixy.events.observe(this.source, "focus", this.focus.b(this))
					Stixy.events.observe(this.source, "blur", this.blur.b(this))
				}
			}
			this.reset();
			return this;
		},
		inputFeatures: {
			formatDigit: function(value, num){
				var val = value.toString();
				while(val.length < (num||2)){
					val = "0" + val
					break
				}
				return val;
			},
			ControledInput: function(element, max, allowed_keys, reset){
				this.reset = reset;
				var keys = [];
				for(var i=0; i<allowed_keys.length; i++){
					keys[allowed_keys[i][0]] = allowed_keys[i][1];
				}
				function getKey(e){
					return keys[e.keyCode];
				}
				this.arrowKeyDown = function(element, e){
					element.value = this.arrowKeys(element.value, e.keyCode==38);
				}
				this.deleteKeyDown = function(element){
					element.value = this.deleteKey(element.value);
				}
				this.keyDown = null;
				this.beforeSet = function(value){ return value };
				this.afterBlur = function(){ };
				this.arrowKeys = function(){ };
				Stixy.events.observe(element, "focus", function(e){ 
					this.count = 0; 
				}.b(this));
				Stixy.events.observe(element, "blur", function(){ this.afterBlur() }.b(this));
				Stixy.events.observe(element, "keyup", function(e){
					clearInterval(this.keyDown)
				}.b(this));
				Stixy.events.observe(element, "keypress", function(e){
					if(e.keyCode!=9 && e.keyCode!=8){
						Stixy.events.stop(e);
					}
				}.b(this));
				Stixy.events.observe(element, "keydown", function(e){
					if(e.keyCode!=9 && e.keyCode!=8){
						Stixy.events.stop(e);
					}
					code = getKey(e);
					if(code!=undefined){
						if(this.reset && this.count==0 && element.value){
							element.value = element.value.replace(/./g,"0")
						}
						var pos = (max && (this.count < max)) ? (this.count++ % max) : (max ? (max-1) : this.count++);
						var characters = element.value.match(/./g);
						if(characters){
							var members = characters.reverse();
							members.splice(pos,1)
							members.reverse();
							members.push(code);
						}
						var value = members ? members.join("") : code
						var altered_value = this.beforeSet(value, code);
						if(altered_value!==false){
							element.value = altered_value;
						}
					}else{
						if(e.keyCode==38 || e.keyCode==40){
							this.arrowKeyDown(element, e)
							if(!this.keyDown){
								this.keyDown = setInterval(this.arrowKeyDown.b(this, element, e), 200)
							}
						}
					}
				}.b(this));
			},
			NumberInput: function(element, max, start, stop){
				this.element = element
				this.start = start || 0
				var keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				var control 	= new Stixy.ui.inputFeatures.ControledInput(element, max, keys);
				var setValue = function(value, key){
					return (stop && (value > stop)) ? start : (start && (value < start)) ? start : value;
				};
				control.beforeSet = function(value, key){
					return setValue(value, key);
				}.b(this)
				control.arrowKeys = function(value, up){
					return setValue(Number(value) + (up ? +1 : -1));
				}.b(this)
				control.arrowKeys = function(value, up){
					return setValue(Number(value) + (up ? +1 : -1));
				}.b(this)
				control.afterBlur = function(){
					this.element.value = this.element.value.length > 0 ? this.element.value : this.start
				}.b(this);
			},
			DateInput: function(year, month, day){
				this.year = year;
				this.month = month;
				this.day = day;
				var keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				try{
					this.date = new Date(year.value, (month.value-1), day.value);
				}catch(e){
					this.date = new Date.now();
				}
				this.setValues = function(){
					this.year.value = this.date.getFullYear();
					var month = this.date.getMonth()+1;
					this.month.value = (month > 9 ? month : "0"+month);
					var day = this.date.getDate();
					this.day.value = (day > 9 ? day : "0"+day);
				}
				this.updateDate = function(date){
					this.date = date;
					this.setValues();
				}
				var year_control 	= new Stixy.ui.inputFeatures.ControledInput(year, 4, keys);
				var month_control = new Stixy.ui.inputFeatures.ControledInput(month, 2, keys, true);
				var day_control 	= new Stixy.ui.inputFeatures.ControledInput(day, 2, keys, true);
				year_control.afterBlur 	= this.setValues.b(this);
				month_control.afterBlur = this.setValues.b(this);
				day_control.afterBlur 	= this.setValues.b(this);
				year_control.beforeSet = function(value, key){
					this.date.setFullYear(value);
					return Stixy.ui.inputFeatures.formatDigit(value, 4);
				}.b(this)
				month_control.beforeSet = function(value, key){
					var month = (value > 12) ? (key==0 ? 1:key) : value;
					var lastDay = (new Date(this.date.getFullYear(),month,0)).getDate();
					this.date.setFullYear(this.date.getFullYear(), (month-1), Math.min(this.date.getDate(), lastDay));
					return Stixy.ui.inputFeatures.formatDigit(month);
				}.b(this)
				day_control.beforeSet = function(value, key){
					var lastDay = (new Date(this.date.getFullYear(),(this.date.getMonth()+1),0)).getDate();
					var day = (value > lastDay) ? (key==0 ? 1:key) : value;
					this.date.setFullYear(this.date.getFullYear(), this.date.getMonth(), day);
					return Stixy.ui.inputFeatures.formatDigit(day);
				}.b(this)
				year_control.arrowKeys = function(value, up){
					year = (Number(value) + (up ? 1 : -1));
					this.date.setFullYear(year, (this.date.getMonth()), this.date.getDate());
					return Stixy.ui.inputFeatures.formatDigit(year);
				}.b(this)
				month_control.arrowKeys = function(value, up){
					var month = Number(value) + (up ? 1 : -1);
					month = (month > 12) ? 1: month;
					month = (month==0) ? 12: month;
					var lastDay = (new Date(this.date.getFullYear(),month,0)).getDate();
					this.date.setFullYear(this.date.getFullYear(), (month-1), Math.min(this.date.getDate(), lastDay));
					return  Stixy.ui.inputFeatures.formatDigit(month);
				}.b(this)
				day_control.arrowKeys = function(value, up){
					var lastDay = (new Date(this.date.getFullYear(),(this.date.getMonth()+1),0)).getDate();
					var day = Number(value) + (up ? 1 : -1);
					day = (day > lastDay) ? 1: day;
					day = (day==0) ? lastDay: day;
					this.date.setFullYear(this.date.getFullYear(), (this.date.getMonth()), day);
					return  Stixy.ui.inputFeatures.formatDigit(day);
				}.b(this)
			},
			TimeInput: function(hour, minute, postfix){
				this.hour = hour;
				this.minute = minute;
				this.postfix = postfix;
				var number_keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				
				var hour_control 	= new Stixy.ui.inputFeatures.ControledInput(this.hour, 2, number_keys, true);
				var minute_control = new Stixy.ui.inputFeatures.ControledInput(this.minute, 2, number_keys, true);
				hour_control.afterBlur = function(){
					this.hour.value = Stixy.ui.inputFeatures.formatDigit(this.hour.value.length > 0 ? this.hour.value : 0)
				}.b(this);
				minute_control.afterBlur = function(){
					this.minute.value = Stixy.ui.inputFeatures.formatDigit(this.minute.value.length > 0 ? this.minute.value : 0)
				}.b(this);
				
				this.updateTime = function(date){
					var hour = date.getHours();
					this.hour.value = Stixy.ui.inputFeatures.formatDigit((postfix && (hour > 12)) ? (hour-12) : hour);
					this.minute.value = Stixy.ui.inputFeatures.formatDigit(date.getMinutes());
					if(this.postfix){
						this.postfix.value = (hour > 11) ? "PM" : "AM";
					}
				}.b(this)
				hour_control.beforeSet = function(value, key){
					var time = (value > (postfix ? 12 : 23)) ? (key==0 ? (postfix ? 1 : 0):key) : value < (postfix ? 1 : 0) ? (postfix ? 1 : 0) : value;
					return Stixy.ui.inputFeatures.formatDigit(time);
				}.b(this)
				minute_control.beforeSet = function(value, key){
					var time = (value > 59) ? (key==0 ? 1:key) : value;
					return Stixy.ui.inputFeatures.formatDigit(time);
				}.b(this)
				hour_control.arrowKeys = function(value, up){
					var hour = Number(value) + (up ? 1 : -1);
					hour = (hour > (postfix ? 12 : 23)) ? (postfix ? 1 : 0): hour;
					hour = (hour==(postfix ? 0 : -1)) ? (postfix ? 12 : 23): hour;
					return  Stixy.ui.inputFeatures.formatDigit(hour);
				}.b(this)
				minute_control.arrowKeys = function(value, up){
					var minute = Number(value) + (up ? 1 : -1);
					minute = (minute > 59) ? 0: minute;
					minute = (minute<0) ? 59: minute;
					return  Stixy.ui.inputFeatures.formatDigit(minute);
				}.b(this)

				if(postfix){
					var postfix_control 	= new Stixy.ui.inputFeatures.ControledInput(this.postfix, 2, [[65,"A"],[80,"P"]]);
					postfix_control.beforeSet = function(value, key){
						return key.toUpperCase()=="A" ? "AM" : "PM";
					}.b(this)
					postfix_control.arrowKeys = function(value, up){
						return  (value.search(/p/i) >= 0) ? "AM" : "PM";
					}.b(this)
				}
			},
			GroupToogle: function(switcher, base, ghost_class, elements, on, off){
				this.switcher = switcher;
				this.base = base;
				this.ghost_class = ghost_class;
				this.elements = elements;
				this.on = on;
				this.off = off;
				this.activate = function(update_switch){
					this.announce("activate")
					if(this.elements) Stixy.element.form.setFieldsProperty(this.elements, "disabled", false)
					Stixy.element.removeClassName(this.base, this.ghost_class);
					if(update_switch!==false){ Stixy.element.form.setValue(this.switcher, "checked") };
					if(this.on){ this.on.call(this) }
				}
				this.deactivate = function(update_switch){
					this.announce("deactivate")
					if(this.elements) Stixy.element.form.setFieldsProperty(this.elements, "disabled", "disabled")
					Stixy.element.addClassName(this.base, this.ghost_class);
					if(update_switch!==false){ Stixy.element.form.setValue(this.switcher, false) };
					if(this.off){ this.off.call(this) }
				}
				Stixy.events.observe(this.switcher, "mouseup", function(event){
					Stixy.events.stop(event)
					if(this.switcher.checked==false){
						this.activate(false);
					}else{
						this.deactivate(false);
					}
				}.b(this));
			}
		}
	}
});

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
  	    }catch(e){ new StixyError(e, "030_widgets.js line 352") }
    	  
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
  if(attr["remove"]){
		this.properties = 0
    if(this.number==0) { Stixy.server.removeFromQue(this) }
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

// Tools			
Stixy.extend(Stixy, {
	tools: {
		cashed_tools: [],
		addToToolbar: function(){
			for(var i=0; i<arguments.length;i++){
				var widget = arguments[i][0];
				var element = Stixy.element.$ID(arguments[i][1]);
				this.cashed_tools.push(new function(){
		      this.widget = widget;
		      this.element = element;
		      this.small = element.cloneNode(true);
		      this.small.style.display = "none";
					this.element.parentNode.parentNode.appendChild(this.small);
		      this.smallOffsetX = 0;
		      this.smallOffsetY = 0;
					this.droparea = {
		        element: function(){
							return Stixy.ui.canvas;
						},
		        offsetHeight: 165, left: 0, top: 0, right: 0, bottom: 0, offsetWidth: 0, offsetLeft: 0, offsetTop: 0
		      }
					this.createWidget = function(){
						var large = Stixy.element.$CN("widget",this.element)[0].cloneNode(true);
		        large.id = Stixy.tempID.get();
						large.style.zIndex = 100000000;
		        large.style.display = "none";
		    		this.element.parentNode.appendChild(large);
						this.large = large;
						return large;
					}
					this.createWidget();
					this.move = new Stixy.features.Move(this, {source:this.element,target:this.small,droparea:this.droparea});
					this.move.listen("beforemove", function(event){
						this.droparea.bottom = document.body.clientHeight - this.droparea.offsetHeight;
		        this.droparea.right = document.body.clientWidth - this.droparea.offsetWidth;
		      	this.droparea.element().appendChild(this.large);
						this.move.offsetX = event.clientX - this.element.parentNode.offsetLeft;
				    this.move.offsetY = event.clientY - this.element.parentNode.offsetTop;
		      	this.small.style.left = this.move.offsetX + "px";
						this.small.style.top = this.move.offsetY + "px";
						this.small.style.display = "block";
					}.b(this));
		      this.move.listen("aftermove", function(){
		        this.small.style.display = "none";
		        this.small.style.left = "0px";
		        this.small.style.top = "0px";
		        if(this.move.inside){
		          var widget = new this.widget(this.large.id)
							widget.announce("drop");
							this.createWidget();
		        }
						this.move.target = this.small;
						this.move.inside = false;
		      }.b(this));
		      this.move.listen("enterdroparea", function(){
						this.large.style.visibility = "hidden";
		        this.large.style.display = "block";
		        this.smallOffsetX = this.move.offsetX;
		        this.smallOffsetY = this.move.offsetY;
						this.move.offsetX = (this.large.scrollWidth/2)-this.droparea.element().scrollLeft+this.droparea.element().offsetLeft; 
		        this.move.offsetY = (this.large.scrollHeight/2)-this.droparea.element().scrollTop;
						this.move.minX = this.large.clientWidth-10; 
		        this.move.minY = this.large.clientHeight-70;
		        this.large.style.visibility = "visible";
		        this.small.style.display = "none";
		        this.move.target = this.large;
		      }.b(this));
		      this.move.listen("leavedroparea", function(){
		        this.large.style.display = "none";
		        this.small.style.display = "block";
						this.move.offsetX = this.smallOffsetX;
		        this.move.offsetY = this.smallOffsetY;
		        this.move.target = this.small;
		      }.b(this));
				});
			}
		}
	}
});

Stixy.widgets.Optionbar = new Object;
Stixy.widgets.Optionbar.create = function(){
  this.tools = [];
  this.widget = null;
	this.base = null;
	this.panel = null;
	//this.state = "loaded";
  this.register = function(sources, eventtype, name){
		var optionbar = this;
		var tool = new function(){
			this.name = name || undefined;
      this.optionbar = optionbar;
      this.sources = (sources.nodeType) ? [sources] : sources;
			this.source = (sources.nodeType) ? sources : this.sources[0];
			this.current = null;
			this.eventtype = eventtype || "mouseup";
			this.command = this.update = this.activate = this.deactivate = function(){ };
      this.save = null;
			this.eventActivated = function(){
        this.active = true;
        this.activate(true);
      }.b(this);
      this.eventDeactivated = function(){
				this.active = false;
        this.deactivate(false);
      }.b(this);
      this.eventUpdate = function(){
				if(this.active) { this.update(false) };
      }.b(this);
      this.activatedBy = function(object, event, append, debug){
				this.activator[0][((append) ? this.activator[0].length:0)] = [object, event, this.eventActivated];
			}
      this.deactivatedBy = function(object, event, append){
				this.activator[1][((append) ? this.activator[1].length:0)] = [object, event, this.eventDeactivated];
      }
      this.updatedWhen = function(object, event, append){
				this.activator[2][((append) ? this.activator[2].length:0)] = [object, event, this.eventUpdate];
      }
			this.activator = 	[	[[this.optionbar, "ready", this.eventActivated]],
      										[[this.optionbar, "hide", this.eventDeactivated]],
      										[[this.optionbar, "ready", this.eventUpdate]]];

			this.__toggle = function(target, rule, add){
        rule = rule || "active";
        target = target || this.current;
        if(target){
					if(add) { Stixy.element.addClassName(target, rule) }
          else { Stixy.element.removeClassName(target, rule) }
        }
      }
			this.turnon = function(rule){
				this.__toggle(null, rule, true)
      }
      this.turnoff = function(target, rule){
        this.__toggle(null, rule, false)
      }
      this.state = function(current, status, rule){
        if(status!=null) { this.status = status }
        if(this.status!=true) { this.turnoff(rule) }
        this.current = current;
        if(this.status!=false) { this.turnon(rule) }
        if(this.status!=null) { this.status = (this.status) ? false : true }
      }
			this.unregister = function(){
				for(var i=0; i<this.sources.length; i++){
					var source = this.sources[i];
					Stixy.events.stopObserving(source, this.eventtype, this.registerEvent.b(this, source));
				}			
				for(var i=0; i<3; i++){
					for(var x=0; x<this.activator[i].length; x++){
						var o = this.activator[i][x];
						var e = (o[0] instanceof Function) ? o[0]():o[0];
						e.unlisten(o[1], o[2]);
					}
				}
			}
			this.registerActivation = function(){
				this.widget = this.optionbar.widget;
				for(var i=0; i<3; i++){
					for(var x=0; x<this.activator[i].length; x++){
						var o = this.activator[i][x];
						var e = (o[0] instanceof Function) ? o[0]():o[0];
			      e.listen(o[1], o[2]);
					}
				}
			}
			this.registerDeactivation = function(){
				for(var i=0; i<3; i++){
					for(var x=0; x<this.activator[i].length; x++){
						var o = this.activator[i][x];
						var e = (o[0] instanceof Function) ? o[0]():o[0];
						e.unlisten(o[1], o[2]);
					}
				}
			}
			this.registerEvent = function(source){
				if(this.active){
         	this.state(source);
					this.source = source;
					this.command();
         	if(this.save) { this.optionbar.widget.save(this.save()) }
				}
			}
			this.optionbar.listen("beforeinitialize", this.registerActivation.b(this));
			this.optionbar.listen("hide", this.registerDeactivation.b(this));
			for(var i=0; i<this.sources.length; i++){
				var source = this.sources[i];
				if(source.all && !(source.tagName.toLowerCase() == "input" && source.getAttribute("type").toLowerCase() == "text")){
					source.unselectable = "on";
					Stixy.element.addClassName('opt-bar-controller');
				}
        else if(!source.all && source.tagName.toLowerCase() != "select"){
          Stixy.events.observe(source, "mousedown", function(e){
            Stixy.events.stop(e);
          }, false);
        }
				Stixy.events.observe(source, this.eventtype, this.registerEvent.b(this, source))
			}
    }
    this.tools.push(tool);
		return tool;
  }
	this.unregister = function(t,n){
		for(var i=0; i<this.tools.length; i++){
			var tool = this.tools[i];
			if(tool==t||(n!=undefined && tool.name==n)){
				tool.optionbar.unlisten("beforeinitialize", tool.registerActivation.b(tool));
				tool.optionbar.unlisten("hide", tool.registerDeactivation.b(tool));
				tool.unregister();
				this.tools.splice(i, 1);
				tool = null;
				return true;
			}
		}
		return false;
  }
  this.show = function(widget,initialize){
		this.widget = widget;
		this.base = this.base || Stixy.element.$ID("opt_bar");
		if(Stixy.widgets.Optionbar.getAutoShow()) Stixy.ui.woptOpen();
		Stixy.element.replaceClassName(Stixy.ui.base,"widget-deactivated","widget-activated");
		Stixy.element.replaceClassName(this.panel,"wopt-deactivated","wopt-activated");
		this.announce("show");
		if(Stixy.browser=="ie6"){
			var _scope = this;
			var eventInitialize = function(){
				_scope.widget.focus.unlisten("deactivated", eventInitialize);
				_scope.initialize();
			}
			this.widget.focus.listen("deactivated", eventInitialize)
		}else{
			this.initialize();
		}
	}
	this.initialize = function(){
		this.announce("beforeinitialize");
		// Put initialization code for optionbar here, if needed.
		this.announce("ready");
	}
	this.close = function(){
		Stixy.element.replaceClassName(Stixy.ui.base,"widget-activated","widget-deactivated");
		Stixy.element.replaceClassName(this.panel,"wopt-activated","wopt-deactivated");
		Stixy.ui.woptClose();
  }
	this.hide = function(){
		this.close();
    this.announce("hide");
    this.widget = null;
  }
}
Stixy.widgets.Optionbar.frame = new Object;
Stixy.listen("ready",function(){
	try{
		Stixy.widgets.Optionbar.frame.window = document.frames("widget_options_frame");
	}catch(e){
		Stixy.widgets.Optionbar.frame.window = Stixy.element.$ID("widget_options_frame");
	}
	Stixy.events.beforeUnload(function(){
		Stixy.widgets.Optionbar.frame.window = null
	})
});
Stixy.widgets.Optionbar.setAutoShow = function(value){
	this.autoShow = value||0;
}
Stixy.widgets.Optionbar.getAutoShow = function(){
	return this.autoShow == 1;
}

Stixy.widgets.Optionbar.create.prototype.defaultSet = new Stixy.widgets.Optionbar.create;
Stixy.widgets.Optionbar.create.prototype.defaultSet.loadSet = function(){
	if(this.loaded) return;
	Stixy.features.Focus.prototype.global.listen("newfocus", function(widget){
		this.optionbar = widget.optionbar;
		this.widget = widget;
		this.announce("optionbarloaded")
		
	}.b(this))
	function activetedBy(object, tool){
		object.listen("optionbarloaded", tool.eventActivated)
	}
	function updatedBy(object, tool){
		object.listen("optionbarloaded", tool.eventUpdate)
	}
	function deactivetedBy(tool){ }
	var panel = Stixy.element.$ID("wopt_common_tools");
	this.movetop = this.register(Stixy.element.$CN("w-top", panel),null,"move-top");
	this.movetop.command = function(){ this.optionbar.widget.order.changeOrder(1,true)  }.b(this.movetop);
	activetedBy(this, this.movetop);
	deactivetedBy(this, this.movetop);
	
	this.movebottom = this.register(Stixy.element.$CN("w-bottom", panel),null,"move-bottom");
	this.movebottom.command = function(){ this.optionbar.widget.order.changeOrder(0,true) }.b(this.movebottom);
	activetedBy(this, this.movebottom);
	deactivetedBy(this, this.movebottom);
	
	this.automove = this.register([Stixy.element.$ID("widget_bring_forward"), Stixy.element.$ID("widget_bring_forward_title")],null,"move-auto");
	this.automove.command = function(){ this.optionbar.widget.order.stay = (this.optionbar.widget.order.stay) ? false:true }.b(this.automove);
	this.automove.update = function(){ 
		var checkbox = this.source.htmlFor ? Stixy.element.$ID(this.source.htmlFor) : this.source;
	  checkbox.checked = this.optionbar.widget.order.stay ? null : true;
	}.b(this.automove);
	this.automove.save = function(){ 
	  var stay = (this.optionbar.widget.order.stay) ? "1":"0";
	  return {auto_front:stay}
	}.b(this.automove);
	activetedBy(this, this.automove);
	deactivetedBy(this, this.automove);
	updatedBy(this, this.automove);

	this.shadow = this.register([Stixy.element.$ID("widget_drop_shadow"), Stixy.element.$ID("widget_drop_shadow_title")],null,"shadow");
	this.shadow.command = function(){ 
		Stixy.element.toggleClassName(this.optionbar.widget.element, "no-drop-shadow") }.b(this.shadow);
	this.shadow.update = function(){
	  this.source.removeAttribute("disabled");
	  var shadowstate = (Stixy.element.hasClassName(this.optionbar.widget.element, "no-drop-shadow")) ? false:true;
	  var checkbox = this.source.htmlFor ? Stixy.element.$ID(this.source.htmlFor) : this.source;
		checkbox.checked = shadowstate ? true : null;
	  this.announce("update");
	}.b(this.shadow);
	this.shadow.save = function(){
	  var state = (Stixy.element.hasClassName(this.optionbar.widget.element, "no-drop-shadow")) ? "0":"1"
	  return {shadow:state};
	}.b(this.shadow);
	this.shadow.disable = function(){
	  Stixy.element.addClassName(this.source, "ghosted");
	  this.source.setAttribute("disabled", true);
	}.b(this.shadow);
	this.shadow.enable = function(){
	  Stixy.element.removeClassName(this.source, "ghosted");
	  this.source.removeAttribute("disabled");
	}.b(this.shadow);
	activetedBy(this, this.shadow);
	deactivetedBy(this, this.shadow);
	updatedBy(this, this.shadow);
	
	this.locked = this.register([Stixy.element.$ID("widget_locked"), Stixy.element.$ID("widget_locked_title")],null,"locked");
	this.locked.command = function(com){
		Stixy.element.toggleClassName(Stixy.element.$ID("opt_bar"), "wopt-locked"); 
		var state = Stixy.element.toggleClassName(this.optionbar.widget.element, "widget-locked");
		this.optionbar.widget.lock(state);
	}.b(this.locked);
	this.locked.update = function(){
		if(this.optionbar.widget.locked){
			Stixy.element.addClassName(Stixy.element.$ID("opt_bar"), "wopt-locked");
		}else{
			Stixy.element.removeClassName(Stixy.element.$ID("opt_bar"), "wopt-locked");
		}
		var checkbox = this.source.htmlFor ? Stixy.element.$ID(this.source.htmlFor) : this.source;
		checkbox.checked = this.optionbar.widget.locked ? true : null;
	  this.announce("update");
	}.b(this.locked);
	this.locked.save = function(){
	  var state = (Stixy.element.hasClassName(this.optionbar.widget.element, "widget-locked")) ? "1":"0"
	  return {locked:state};
	}.b(this.locked);
	activetedBy(this, this.locked);
	deactivetedBy(this, this.locked);
	updatedBy(this, this.locked);
	
	this.loaded = true;
}

Stixy.widgets.Base.prototype.loadOptionbar = function(element_id){
	this.optionbar = new Stixy.widgets.Optionbar.create;
	this.optionbar.defaultSet.loadSet();
	this.optionbar.panel = document.getElementById(element_id);
	//Stixy.events.observe(this.optionbar.panel, 'mousedown', function(e){
	//  //Stixy.events.stop(e);
	//  console.log(123)
	//})
	//this.optionbar.panel = Stixy.widgets.Optionbar.frame.window.doc.getElementById(element_id);
	return this.optionbar;
}

// Catch external links, and open them in a new window/tab
Stixy.events.observe(document,"click",function(e){
	var element = Stixy.events.element(e);
	var uri = element.href;
	if(uri && element.tagName.toLowerCase()=="a" && (uri.search(new RegExp("^"+location.protocol+"\/\/"+location.host))==-1)){
		Stixy.events.stop(e);
		Stixy.openExternalWindow(uri)
	}
});
Stixy.events.beforeUnload(function(){
	Stixy.board.announce("unload")
});
Stixy.events.observe(window, 'unload', Stixy.events.unloadCache.b(Stixy.events), false);
Stixy.events.observe(document, "keydown", function(event){
	Stixy.events.setKey(event.keyCode);
	if(event.altKey){
		Stixy.element.addClassName(document.body, "alt-key-down");
		var key_up = function(event){
			Stixy.element.removeClassName(document.body, "alt-key-down");
			Stixy.events.stopObserving(document, "keyup", key_up);
		}
		Stixy.events.observe(document, "keyup", key_up);
	}
});
Stixy.events.observe(document, "keyup", function(event){
	Stixy.events.setKey(event.keyCode, false);
});

// DOMContentLoaded
Stixy.listen("ready",function(){
	// Ad frame stuff
	var top_ad = Stixy.element.$ID('global_top_ad_frame');
	if(top_ad){
	  // move ad to one level below popup. Initialy, it sits above the load/error popup so the ad works before everything is loaded
    top_ad.style.zIndex = 999;
	  Stixy.board.listen("beforenavigate", function(){
  		top_ad.contentWindow.location.reload()
		});
		Stixy.popup.listen("close", function(){
  		top_ad.contentWindow.location.reload()
		});
	}

	var canvas = Stixy.element.$ID('stixyboard');
	if(canvas){
		function delayedScroll(){
			clearTimeout(Stixy.ui.__scroll_save_delay);
			Stixy.ui.__scroll_save_delay_set = true;
			Stixy.ui.__scroll_save_delay = setTimeout(function(){
				Stixy.ui.__scroll_save_delay_set = false;
				Stixy.ui.saveScroll();
			}.b(this),1000);
		}
		if(Stixy.ua.safari && Stixy.ua.major < 4){
		  Stixy.events.observe(window, "scroll", function(e){
			  if(Stixy.events.element(e)==Stixy.ui.canvas){
					delayedScroll();
				}
			});
		}else{
			Stixy.ui.listen("scrolltoposition", function(){
				Stixy.ui.__no_scroll_save = true;
			});
			Stixy.events.observe(canvas, "scroll", function(e){
				Stixy.events.stop(e);
				if(Stixy.ui.__no_scroll_save!=true){
					delayedScroll();
				}else{
					Stixy.ui.__no_scroll_save = false;
				}
			},true);	
		}
		Stixy.board.listen("unload", function(){
			if(Stixy.ui && Stixy.ui.__scroll_save_delay_set){
				clearTimeout(Stixy.ui.__scroll_save_delay);
				Stixy.ui.saveScroll();
				Stixy.ui.__scroll_save_delay_set = false;
			}
		});
	}

	Stixy.widgets.Optionbar.frame.announce("ready");
	var scroll_source = Stixy.element.$ID("stixyboard_hand_scroll");
	var scroll_target = Stixy.element.$ID("stixyboard");
	if(scroll_source && scroll_target){
		var canvas_scroll = Stixy.features.Scroll(null, {source:scroll_source,target:scroll_target});
	}
});

// Widgets loaded
Stixy.listen("ready", function(){
	setTimeout(function(){
		var widget_id = document.location.pathname.match(/^\/board\/\d+\/widget\/(\d+)/)
		if(widget_id){
			try{
				Stixy.widgets.getWidget(widget_id[1]).scrollIntoView(true, /\/edit/.test(document.location.pathname)); 
			}catch(e){ }
		}
	},100)
});

// DOMContentLoaded
Stixy.listen("ready",function(){
	var load_error_frame = Stixy.element.$ID("load_error_frame");
	if(load_error_frame){
		try{
  		load_error_frame.parentNode.removeChild(load_error_frame);
    }catch(e){ new StixyError(e, "033_event_observers.js line 94") }
	}
});


/* Support for the DOMContentLoaded event is based on work by Dan Webb,
   Matthias Miller, Dean Edwards and John Resig. */
(function() {
  var loaded = false;
  (function(loaded) {
    var timer;
    function fireContentLoadedEvent(){
      if(loaded) return
      if(timer) window.clearInterval(timer);
      //if(window.parent) window.parent.console.log(9999)
      Stixy.state.ready = true;
      loaded = true;
      Stixy.announce("ready");
    }
    if(document.addEventListener){
     if(Stixy.ua.webkit) {
       timer = window.setInterval(function(){
         if(/loaded|complete/.test(document.readyState)){
           fireContentLoadedEvent();
         }
       }, 0);
       Stixy.events.observe(window, "load", fireContentLoadedEvent);
     }else if(Stixy.ua.firefox && Stixy.ua.major < 3 && window.frameElement){
       // Firefox 2 doesn't fire DOMContentLoaded for frames
       Stixy.events.observe(window, "load", fireContentLoadedEvent);
     }else{
       document.addEventListener("DOMContentLoaded", fireContentLoadedEvent, false);
     }
    }else{
      document.write("<script id=__onDOMContentLoaded defer src=//:><\/script>");
      document.getElementById('__onDOMContentLoaded').onreadystatechange = function(){
        if(this.readyState == "complete") {
          this.onreadystatechange = null;
          fireContentLoadedEvent();
        }
      }
    }
  })(loaded);
})();


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
        replace: {"popup_content": "<form action=\"http://localhost:3000/widgets/documents\" enctype=\"multipart/form-data\" method=\"post\">\n\t<input type=\"hidden\" name=\"board_id\" value=\"0\">\n\t<input type=\"hidden\" name=\"upload_id\" id=\"upload_id\" value=\"f21a0dd58520782525ff2cad63c21731\">\n\t<input type=\"hidden\" value=\"www.example.com\" name=\"host\">\n\t<h2 style=\"margin-bottom:0px;\">Add a document</h2>\n\t\n\t<div class=\"description\" style=\"margin:4px 0 10px\">Browse your computer for a document, and click \"Add document\" to upload your document to Stixy.</div>\n\t\n\t\n  <input type=\"file\" name=\"document[file]\" style=\"width:300px;\">\n  <input type=\"submit\" style=\"display:none;\">\n</form>\n<div style=\"margin:8px 0 10px\">\n\t<div style=\"color:rgb(150,150,150)\">Maximum file size: 50MB</div>\n</div>\n", "popup_buttons": "<sx:button onmouseover=\"Stixy.events.stop(event)\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"window.parent.Stixy.popup.cancel(); return false;\">Cancel</a></sx:t></sx:button>\n<sx:button class=\"default\" onmouseover=\"Stixy.events.stop(event)\" style=\"margin-left:10px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"loadDocument(); return false;\">Add document</a></sx:t></sx:button>"}
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

Stixy.widgets.Note = function(element_id,attributes){
	this.constructor = Stixy.widgets.Note;
	this.value = element_id;
	this.attributes = attributes || {};
  this.type = 1;
	this.activate = function(){
	  Stixy.widgets.Base.call(this)
		this.initialize("note",element_id,this.attributes);
		
		/* 
			Scrollbars is not yet ready for production. Things still needed to be developed are:
			
			* Scrollbars for the editor iframe are needed
			* Figure out how to scroll the editor when the caret moves below the scroll
			* Port scrollbar functionality to IE
			* Add variable speed functionality (faster scroll when draging the cursor away from the arrow)
			* Design
		*/
		
		// this.scrollbar = new	Stixy.features.Scroll(this, { target: this.text.source });
		// this.hover.listen("enter", function(){ this.scrollbar.autoState() }.b(this));
		// this.hover.listen("leave", function(){ this.scrollbar.setState(false) }.b(this));
		// this.resize.listen("resize", function(){ this.scrollbar.autoState() }.b(this));
		// this.text.editor.listen("beforecreate", function(){
		// 	this.scrollX = this.scrollbar.getScrollPosition("x");
		// 	this.scrollY = this.scrollbar.getScrollPosition("y");
		// }.b(this));
		// this.text.editor.listen("beforepopulateeditor", function(){
		// 	this.scrollbar.target = this.text.editor.window.contentWindow;
		// 	this.scrollbar.setScrollPosition(this.scrollX,this.scrollY);
		// }.b(this));
		// this.text.editor.listen("create", function(){
		// 	//this.scrollbar.target.scrollTo(this.scrollX,this.scrollY) 
		// }.b(this));
		
		var themeName = this.element.className.match(/(?:^|| )(wopt-theme-.)(?:$|| )/);
	  this.theme = (themeName) ? themeName[1]:null;
	  this.listen("drop", function(){
	    this.text.source.focus(); // First we need to set the focus to the element, or the anchorNode will be the body element
      this.text.focus();
	    this.save({text:{value:this.text.getSource.b(this.text)}});
	  }.b(this));
		this.active = true;
	}
	this.activate();
}
Stixy.widgets.Note.prototype = new Stixy.widgets.Base;

// OPTIONBAR

try{
	Stixy.widgets.Optionbar.frame.listen("ready",function(){
		var optionbar = Stixy.widgets.Note.prototype.loadOptionbar("wopt-note");
		function getComputedStyle(tool, property_name){
			try{
				var node = tool.widget.text.selection.focusNode;
				node = node.nodeType==1 ? node : node.parentNode;
				return document.defaultView.getComputedStyle(node, null).getPropertyValue(property_name);
			}catch(e){
				return null;
			}
		}
	  function setText(tool, command, value){
			if(document.body.setActive) tool.widget.text.source.setActive();
			if(/rgb\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)/g.test(value)){
				var color_array = value.match(/\d+/g);
				var value = "#" + RGBtoHex(color_array[0],color_array[1],color_array[2])
			}
      tool.widget.text.getDocument().execCommand(command, false, value);
			tool.widget.text.giveFocus();
			if(document.body.setActive){
				tool.update();
			}
	  }
	  function valueOfText(tool, command){
	    try{
	      if(tool.widget.text.getDocument().queryCommandEnabled(command)){
    			var value = tool.widget.text.getDocument().queryCommandValue(command);
  	    }
	    }catch(e){
	      new StixyError(e, "COMMAND: " + command)
	    }
			tool.state();
			return value;
	  }
		function setCommonState(tool, command, sources, test){
			var value = valueOfText(tool, command);
			for(var i=0; i<sources.length; i++){
				if(test(sources[i],value)){
					tool.state(sources[i]);
					return true;
				}
	    }
	  }
		function setSwatchState(tool, command, sources, test){
			var value = valueOfText(tool, command);
			for(var i=0; i<sources.length; i++){
				if(test(sources[i],value)){
					tool.state(sources[i].parentNode);
				}
	    }
	  }
	  function stateOfText(tool, command){
	    try{
	      if(tool.widget.text.getDocument().queryCommandEnabled(command)){
    	    tool.state(tool.source, tool.widget.text.getDocument().queryCommandState(command));
  	    }
	    }catch(e){
	      //new StixyError(e, "COMMAND: " + command)
	    }
	  }
	  function textActivators(object){
	    object.activatedBy(function(){ return this.widget.text }.b(object), "gotfocus");
	    object.deactivatedBy(function(){ return this.widget.text }.b(object), "lostfocus");
	    object.updatedWhen(function(){ return this.widget.text }.b(object), "textselected");
	  }
		function textActivation(object){
			object.activate = function(){
				for(var i=0; i<this.sources.length; i++){
					Stixy.element.addClassName(this.sources[i], "activated")
				}
			}
			object.deactivate = function(){
				for(var i=0; i<this.sources.length; i++){
					Stixy.element.removeClassName(this.sources[i], "activated")
				}
			}
		}
		function swatchActivation(object){
			object.activate = function(){
				Stixy.element.removeClassName(this.sources[0].parentNode.parentNode, "deactivated")
			}
			object.deactivate = function(){ 
				Stixy.element.addClassName(this.sources[0].parentNode.parentNode, "deactivated")
			}
		}
	  function textSave(option){
	    option.save = function(){ return {text:{value:this.optionbar.widget.text.getSource()}}};
	  }
		function getActiveOption(selectelement){
			return selectelement.options[selectelement.selectedIndex];
		}
		function RGBtoHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B)}
		function toHex(N) {
		 if (N==null) return "00";
		 N=parseInt(N); if (N==0 || isNaN(N)) return "00";
		 N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
		 return "0123456789ABCDEF".charAt((N-N%16)/16)
		      + "0123456789ABCDEF".charAt(N%16);
		}
		function toRGB(v) {
 		  if(typeof v != "number") return v;
 		  return "rgb(" + (v & 0xFF) + "," + ((v >> 8) & 0xFF) + "," + ((v >> 16) & 0xFF) + ")";
 		}
		
// Clone
 // var clone = optionbar.register(Stixy.element.$CN("w-n-clone", optionbar.panel)[0]);
 // 	clone.command = function(){
 // 		var sibling = this.widget;
 // 		for(var i=0; i<1; i++){
 // 			var sibling = this.widget.addSibling();
 // 			sibling.focus.giveFocus();
 // 		}
 // }.b(clone);


// Note themes var theme = optionbar.register(Stixy.element.$CN("wopt-theme", optionbar.panel));
  var theme = optionbar.register(Stixy.element.$CN("wopt-theme", optionbar.panel),null,"theme");
	theme.command = function(){
	  var range = this.widget.text.selectionToRange();
		this.widget.text.destroy();
    this.widget.text.source.innerHTML = this.widget.text.source.innerHTML.replace(/<\/?(span||font){1}(?= ).*?>/ig,"")
    if(this.widget.theme) Stixy.element.removeClassName(this.widget.element, this.widget.theme);
    Stixy.element.$CN("base",this.widget.element)[0].removeAttribute("style");
		Stixy.element.$CN("base-bg",this.widget.element)[0].removeAttribute("style");
		this.widget.theme = this.source.id.match(/(?:^|| )(wopt-theme-.)(?:$|| )/)[1];
    Stixy.element.addClassName(this.widget.element, this.widget.theme);
    this.widget.text.rangeToSelection(range);
    this.widget.text.focus();
  }.b(theme);
  theme.save = function(){ 
    return {
      style:{className:{value:this.widget.theme,name:"theme"},background_color:{value:"none"}},
      text:{value:this.widget.text.getSource.b(this.widget.text)}
    }
  }

// Link tool

// Click event doesn't work in IE when selection is collapsed. 
// The parent element of the range will be BODY independent of where the click was initiated.
// A workaround we're using mousedown for IE instead of click 
  var textlink = optionbar.register([Stixy.element.$ID("link_text")],(Stixy.ua.ie ? 'mousedown' : 'click'),"insert-link");
  textlink.command = function(){
	  if(Stixy.ua.unless(/Firefox\/2/)){
      this.widget.text.openEditLinkPopup();
    }
  }.b(textlink)
  textActivators(textlink);
  textlink.activate = function(){ 
    Stixy.element.removeClassName(this.source.parentNode.parentNode, "deactivated");
    Stixy.element.removeClassName(this.sources[0], "ghosted") 
  }
  textlink.deactivate = function(){ 
    Stixy.element.addClassName(this.source.parentNode.parentNode, "deactivated");
    Stixy.element.addClassName(this.sources[0], "ghosted") 
  }
  textSave(textlink);
 
// Text color tool
	var textcolor = optionbar.register(Stixy.element.$ID("widget_note_fgcolor").getElementsByTagName("div"),null,"text-color");
	textcolor.command = function(){ 
		setText(this, "forecolor", this.source.style.backgroundColor);
		this.update()
	}.b(textcolor);
  textcolor.update =  function(){ setSwatchState(this, "forecolor", this.sources, function(source,value){ return source.style.backgroundColor == toRGB(value) }) }.b(textcolor);
	textActivators(textcolor);
	swatchActivation(textcolor)
  textSave(textcolor);
// Text style tools
   var fontStyles = ["italic","bold","underline","strikethrough"];
   for(var i=0; i<fontStyles.length; i++){
     var style = optionbar.register(Stixy.element.$ID("widget_note_" + fontStyles[i]),null,fontStyles[i]);
     style.command = function(fontStyle){ setText(this, fontStyle) }.b(style, fontStyles[i]);
     style.update = function(fontStyle){ stateOfText(this, fontStyle) }.b(style, fontStyles[i]);
     textActivators(style);
		 textActivation(style)
     textSave(style);
   }
// Text size tool
	  var textsize = optionbar.register(Stixy.element.$ID("widget_note_size").getElementsByTagName("div"), null,"textsize");
	  textsize.command = function(){ 
			setText(this, "fontsize", this.source.getAttribute("size").split(",")[0]);
		}.b(textsize);
	  textsize.update =  function(){ 
			setCommonState(this, "fontsize", this.sources, function(source,value){ 
				var sizes = source.getAttribute("size").split(",");
				/*
				First check to see if the execCommand fontsize returns same value as the first size value.
				If not, check to see if the computet value of the first element node in the selection has the same value as the last size value.
				If not, return false.
				*/
				return (sizes[1]==parseInt(getComputedStyle(this, "font-size"))) || (sizes[0] == value)|| false ;
			}.b(this))		 
		}.b(textsize);
	  textActivators(textsize);
		textActivation(textsize);
	  textSave(textsize);
		/*var sizeSteps = ["decrease","increase"];
	  for(var i=0; i<sizeSteps.length; i++){
	    var size = optionbar.register(Stixy.element.$ID("widget_note_size_"+sizeSteps[i]));
	    size.command = function(step){ setText(this, step+"fontsize") }.b(size, sizeSteps[i]);
	    textActivators(size);
			textActivation(size);
	    textSave(size);
	  }*/
// Font face tools
		var fontface = optionbar.register(Stixy.element.$ID("widget_note_font"), "change", "fontface");
		fontface.command = function(){ 
			setText(this, "fontname", this.source.value) }.b(fontface);
	  fontface.update =  function(){
			try{
				for(var i=0; i<this.source.options.length; i++){
					if(this.widget.text.getDocument().queryCommandValue("fontname").replace(/"/g,"").toLowerCase() == this.source.options[i].value.toLowerCase()) this.source.options[i].selected = true;
		    }
			}catch(e){}
		}.b(fontface);
	  textActivators(fontface);
		textActivation(fontface);
	  textSave(fontface);
	  fontface.activate = function(){
			Stixy.element.removeClassName(this.source.parentNode.parentNode, "deactivated");
			this.source.removeAttribute("disabled");
		}
	  fontface.deactivate = function(){ 
			Stixy.element.addClassName(this.source.parentNode.parentNode, "deactivated");
			this.source.setAttribute("disabled", true);
		}
	// Text align
	  var align = optionbar.register(Stixy.element.$ID("widget_note_align"), "change", "align");
	  align.command = function(){ setText(this, this.source.value) }.b(align);
	  align.update = function(){ 
			for(var i=0; i<this.source.options.length; i++){
				if(this.widget.text.getDocument().queryCommandState(this.source.options[i].value)) this.source.options[i].selected = true;
	    }
		}
	  textActivators(align);
		align.activate = function(){ 
			Stixy.element.removeClassName(this.source.parentNode, "deactivated");
			this.source.removeAttribute("disabled");
		}
	  align.deactivate = function(){ 
			Stixy.element.addClassName(this.source.parentNode, "deactivated");
			this.source.setAttribute("disabled", true);
		}
	  textSave(align);
	  
	// List type  
	  var list = optionbar.register(Stixy.element.$ID("widget_note_list"), "change", "list");
	  list.command = function(){
			var text = this.widget.text.getDocument();
			var option = this.source.options[this.source.selectedIndex]
			if(document.body.setActive) this.widget.text.source.setActive();
			if(option.value==""){
				if(text.queryCommandState("insertorderedlist")) text.execCommand("insertorderedlist", false, false);
	      if(text.queryCommandState("insertunorderedlist")) text.execCommand("insertunorderedlist", false, false);
	    }else if(!text.queryCommandState(option.value)){
	      text.execCommand(option.value, false, false);
	    }
			if(document.body.setActive){
				this.update();
			}
	  }.b(list);
	  list.update = function(){
			for(var i=this.source.options.length-1; i>=0; i--){
				var source = this.source.options[i];
				try{
		      if(source.value!="" && (this.widget.text.getDocument().queryCommandState(source.value)==true)) break;
				}catch(e){
					// This is most likely due to this.widget.text.getDocument() returning a element that can't be edited 
					// (could be set to display:none or something similar)
					//new StixyError(e, "List update")
				}
	    }
			source.selected = true;
	  }
	  textActivators(list);
		textActivation(list);
	  textSave(list);
	  list.activate = function(){ 
			Stixy.element.removeClassName(this.source.parentNode, "deactivated");
			this.source.removeAttribute("disabled");
		}
	  list.deactivate = function(){ 
			Stixy.element.addClassName(this.source.parentNode, "deactivated");
			this.source.setAttribute("disabled", true);
		}
// Background Switch
	  var backgroundswitch = optionbar.register(Stixy.element.$ID("note_bg_switch"), "click", "background-fill");
	  backgroundswitch.command = function(){ 
	    if(this.source.checked){
	      this.announce("checked");
	      Stixy.element.removeClassName(this.widget.element, "no-background-fill");
	      this.optionbar.defaultSet.shadow.enable();
	    }else{
	      this.announce("unchecked");
	      Stixy.element.addClassName(this.widget.element, "no-background-fill");
	      this.optionbar.defaultSet.shadow.disable(); 
	    }
		}.b(backgroundswitch);
	  backgroundswitch.update = function(){
	    this.source.checked = (Stixy.element.hasClassName(this.widget.element, "no-background-fill")) ? null : true;
	    this.command();
	  }.b(backgroundswitch);
	  backgroundswitch.save = function(){ 
	    var fillstate = (Stixy.element.hasClassName(this.widget.element, "no-background-fill")) ? "0":"1"; 
	    return {style:{fill:fillstate}} 
	  }
// Background color
	  var backgroundcolor = optionbar.register(Stixy.element.$ID("widget_note_bgcolor").getElementsByTagName("div"),null, "background-color");
	  backgroundcolor.command = function(){
			this.state(this.source.parentNode);
	    Stixy.element.$CN("base-bg",this.widget.element)[0].style.backgroundColor = this.source.style.backgroundColor 
		}.b(backgroundcolor);
	  backgroundcolor.update =  function(){
			this.state();
			var element =  Stixy.element.$CN("base-bg",this.widget.element)[0];
			for(var i=0; i<this.sources.length; i++){
				var color = (document.defaultView) ? document.defaultView.getComputedStyle(element,null).getPropertyValue("background-color"):element.style.backgroundColor;
				if(color == this.sources[i].style.backgroundColor){
					this.state(this.sources[i].parentNode);
					break;
				}
	    }
	  }.b(backgroundcolor);
	  backgroundcolor.activatedBy(function(){ return this }.b(backgroundswitch), "checked");
	  backgroundcolor.deactivatedBy(function(){ return this }.b(backgroundswitch), "unchecked");
		swatchActivation(backgroundcolor);
  	backgroundcolor.save = function(){ return {style:{background_color:Stixy.element.$CN("base-bg",this.widget.element)[0].style.backgroundColor}}}.b(backgroundcolor);
	// Background opacity
	  var background_opacity = optionbar.register(Stixy.element.$ID("widget_note_bg_opacity"), "change", "background-opacity");
    background_opacity.command = function(){
  		var element = Stixy.element.$CN("base-bg", this.widget.element)[0];
  		if(element.filters){
  			element.filters.item(0).Opacity = this.source.value*100
  		}else{
  			element.style.opacity = this.source.value;
  		}
  	}.b(background_opacity);
    background_opacity.activate = function(){
    	for(var i=0; i<this.source.options.length; i++){
  			var element = Stixy.element.$CN("base-bg", this.widget.element)[0];
				var opacity = 1;
				if(element.filters){
					var filter = element.filters.item("Alpha");
					if(filter) opacity = (filter.opacity*0.01)
				}else{
					opacity = element.style.opacity;
				}
        if(this.source.options[i].value == opacity){
  				this.source.options[i].selected = true;
  				break;
  			}
  			this.source.options[0].selected = true;
      }
  	}.b(background_opacity);
		background_opacity.save = function(){
			var element = Stixy.element.$CN("base-bg", this.widget.element)[0];
			var val = (element.filters) ? element.filters.item(0).Opacity*0.01 : element.style.opacity;
			return {style:{opacity:val}}
		}.b(background_opacity);
		
		// Reset text formating
    var resettext = optionbar.register([Stixy.element.$ID("reset_text_formating")],null,"reset-text-formating");
    resettext.command = function(){
  	  this.widget.text.resetFormating();
      Stixy.element.removeClassName(this.widget.element, this.widget.theme);
  	}.b(resettext)
  
	});
}catch(e){new StixyError(e)}

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
  upload_backend: "http://localhost:3000/widgets/photos",
	load_metadata_backend: "/widgets/photo/metadata/",
	allowed_filetypes: "*.gif; *.jpg; *.jpeg; *.png; *.GIF; *.JPG; *.JPEG; *.PNG;",
	allowed_filesize: "4000",
	filetype_description: "*.gif, *.jpg, *.png",
	fallback: {
    content: function(params){
      var json = {
        replace: {"popup_content": "<form action=\"http://localhost:3000/widgets/photos\" enctype=\"multipart/form-data\" method=\"post\">\n\t<input type=\"hidden\" name=\"board_id\" value=\"0\">\n\t<input type=\"hidden\" name=\"upload_id\" id=\"upload_id\" value=\"7c1ed56b7420d5ecc658960d01f57406\">\n\t<input type=\"hidden\" value=\"200\" name=\"conditions[width]\" id=\"conditions_width\">\n\t<input type=\"hidden\" value=\"160\" name=\"conditions[height]\" id=\"conditions_height\">\n\t<input type=\"hidden\" value=\"0\" name=\"conditions[rotation]\" id=\"conditions_rotation\">\n\t<input type=\"hidden\" value=\"0\" name=\"conditions[filter]\" id=\"conditions_filter\">\n\t<input type=\"hidden\" value=\"www.example.com\" name=\"host\">\n  <h2 style=\"margin:0;\">Add a photo</h2>\n\t\n\t<div class=\"description\" style=\"margin:4px 0 10px\">Browse your computer for a photo, and click \"Add photo\" to upload your photo to Stixy.</div>\n\t\n  <input type=\"file\" name=\"photo[file]\" style=\"width:300px;\">\n  <input type=\"submit\" style=\"display:none;\">\n</form>\n\n<div style=\"margin:15px 0 10px\">\n\t<div style=\"color:rgb(150,150,150)\">Maximum file size: 4 MB</div>\n\t<div style=\"color:rgb(150,150,150)\">Allowed file formats: JPG, GIF, PNG</div>\n</div>", "popup_buttons": "<sx:button onmouseover=\"Stixy.events.stop(event)\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"window.parent.Stixy.popup.cancel(); return false;\">Cancel</a></sx:t></sx:button>\n<sx:button class=\"default\" onmouseover=\"Stixy.events.stop(event)\" style=\"margin-left:10px;\" onmousedown=\"Stixy.events.stop(event)\"><sx:i>&nbsp;</sx:i><sx:l><sx:p>&nbsp;</sx:p></sx:l><sx:r><sx:p>&nbsp;</sx:p></sx:r><sx:t><a class=\"button-label\" href=\"#\" onclick=\"loadPhoto(); return false;\">Add photo</a></sx:t></sx:button>"}
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

Stixy.widgets.Todo = function(element_id,attributes){
	this.constructor = Stixy.widgets.Todo;
	this.value = element_id;
	this.attributes = attributes || {};
  this.type = 4;
	this.remind =    	this.attributes.remind			||	false;
	this.remindAll = 	(this.attributes.remindAll == undefined) ? true : this.attributes.remindAll;
	this.remindOnly = this.attributes.remindOnly	||	[];
	this.remindAt = 	this.attributes.remindAt		||	null;
	
	this.getReminder = function(){
		if(this.optionbar.remindSwitcher.checked == false){
			return { reminder: {remind_at:0, remind_users:0} }
		}else{
			var users = { 0: (this.optionbar.remindAll.checked==true) ? 1 : 0 };
			for(var i=0; i<this.optionbar.remindList.length; i++){
				var inputElement = this.optionbar.remindList[i];
				users[inputElement.value] = (inputElement.checked) ? 1 : 0;
			}
			return { reminder: { 
					remind_at: this.optionbar.remindAt.value,
					remind_users: users
				}
			}
		}
	}
	this.getTimedate = function(){
		var dates = [];
		var classNames = ["todo-month","todo-day","todo-year","todo-hour","todo-minute","todo-postfix"];
		for(var i=0; i<classNames.length; i++){
			dates.push(Stixy.element.$CN(classNames[i], this.element)[0].innerHTML);
		}
		return  {time: dates[0]+" "+dates[1]+" "+dates[2]+" "+dates[3]+":"+dates[4]+" "+dates[5] }
	}
	this.activate = function(){
	  Stixy.widgets.Base.call(this)
	  this.initialize("todo",element_id,this.attributes);
		this.listen("drop", function(){
	    this.text.source.focus(); // First we need to set the focus to the element, or the anchorNode will be the body element
      this.text.focus();
			this.save(this.getTimedate());
			this.save({text:{value:this.text.getSource.b(this.text)}});
	  }.b(this));
		this.active = true;
	}
	this.activate();
}
Stixy.widgets.Todo.prototype = new Stixy.widgets.Base;

// OPTIONBAR
try{
	Stixy.widgets.Optionbar.frame.listen("ready",function(){
		var optionbar = Stixy.widgets.Todo.prototype.loadOptionbar("wopt-todo");
		var todoClassNames = ["todo-year","todo-month","todo-dayname","todo-day"];
		

		
		function getDateArray(element){
			var dates = [];
			for(var i=0; i<todoClassNames.length; i++){
				dates.push(Stixy.element.$CN(todoClassNames[i], element)[0].innerHTML)
			}
			return dates;
    }

    function getParsedDate(element){
    	var date_array = getDateArray(element);
    	return date_array[0] + "-" + date_array[1] + "-" + date_array[2] + "-" + date_array[3]
    }

    function setSelectElement(tool){
			for(var i=0; i<tool.source.options.length; i++){
				var source = tool.source.options[i];
				if(source.value == Stixy.element.$CN(tool.value, tool.widget.element)[0].innerHTML){
					source.selected = true;
					return source;
				}
			}
    }
		
		function getActiveOption(selectelement){
			return selectelement.options[selectelement.selectedIndex];
		}
		
  	var calendar, nav_prev, nav_next;

 		function calendarInit(){
			calendar = optionbar.register(Stixy.element.$A(Stixy.element.$ID("todo_calendar").getElementsByTagName("td")));
			calendar.command = function(){
				var str = calendar.source.id.split("-");
				for(var i=0; i<todoClassNames.length; i++){
					Stixy.element.$CN(todoClassNames[i], calendar.optionbar.widget.element)[0].innerHTML = str[i];
				}
				if(calendar.selected) Stixy.element.removeClassName(calendar.selected,"calendar-selected-day");
				calendar.selected = calendar.source;
				Stixy.element.addClassName(calendar.selected,"calendar-selected-day");
			};
 			calendar.save = function(){ return calendar.optionbar.widget.getTimedate() }

			nav_prev = Stixy.element.$ID("todo_calendar_nav_previuos")
			nav_next = Stixy.element.$ID("todo_calendar_nav_next")
			Stixy.events.observe(nav_prev,"click", loadCalendar.b(this,nav_prev.title));
			Stixy.events.observe(nav_next,"click", loadCalendar.b(this,nav_next.title));
			return calendar;
 		}

		function calendarReset(){
		  calendar = calendarInit();
  	  if(!calendar.optionbar.widget) return;
		  calendar.active = true;
  	  var str_date = getParsedDate(calendar.optionbar.widget.element);
		  for(var i=0; i<calendar.sources.length; i++){
		  	var source = calendar.sources[i];
		  	if(source.id==str_date){
		  		calendar.selected = source;
		  		Stixy.element.addClassName(calendar.selected,"calendar-selected-day")
		  		return calendar;
		  	}
		  }
  	}
		
		function loadCalendar(date){
		 	optionbar.unregister(calendar);
			Stixy.events.stopObserving(nav_prev,"click",loadCalendar);
			Stixy.events.stopObserving(nav_next,"click",loadCalendar);
			if(calendar.request) return;
	 		Stixy.element.$ID('todo_progress_indicator').style.display = "";
			var date_array = getDateArray(calendar.optionbar.widget.element);
	 		calendar.request = Stixy.server.connect(null,"/widgets/todo/ajax_calendar?calendar_date="+date, 
	 			function(request){ 
	 				Stixy.element.$ID("todo_calendar").innerHTML = request.responseText;
	 				calendarReset();
			  	calendar.request = null;
	 			});
		}
		
		calendarInit();
		
		calendar.activate = function(){
 			if(this.request) return;
 			Stixy.element.$ID('todo_progress_indicator').style.display = "";
 			var date_array = getDateArray(this.widget.element);
			this.request = Stixy.server.connect(null,"/widgets/todo/ajax_calendar?year=" + date_array[0] + "&month_name=" + date_array[1], 
 				function(request){ 
 					Stixy.element.$ID("todo_calendar").innerHTML = request.responseText;
 					calendarReset();
 					this.request = null;
 				}.b(this) 
 			);
 		}.b(calendar);
		

		var todo_view = optionbar.register([Stixy.element.$ID("todo_full_view"),Stixy.element.$ID("todo_compact_view")], "click","todo_view")
		todo_view.command = function(){ 
		  if(this.source.value=="full"){
				Stixy.element.removeClassName(this.widget.element, "todo-compact");
			}else{	
				Stixy.element.addClassName(this.widget.element, "todo-compact");
			}
		}.b(todo_view);
		todo_view.activate = function(){
			if(Stixy.element.hasClassName(this.widget.element, "todo-compact")){
				this.sources[1].checked = true;
			}else{
				this.sources[0].checked = true;
			}
		}.b(todo_view)
		todo_view.save = function(){
			return {
				style:{view:{value:(Stixy.element.hasClassName(this.widget.element, "compact")) ? 1:0}}
			}
		}.b(todo_view)

		 var hour = optionbar.register(Stixy.element.$ID("todo_hour"), "change")
		 hour.value = "todo-hour";
		 hour.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(hour);
		 hour.activate = function(){ setSelectElement(this) }.b(hour)
		 hour.save = function(){ return this.widget.getTimedate() }.b(hour)
		 		
		 var minute = optionbar.register(Stixy.element.$ID("todo_minute"), "change")
		 minute.value = "todo-minute";
		 minute.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(minute);
		 minute.activate = function(){ setSelectElement(this) }.b(minute)
		 minute.save = function(){ return this.widget.getTimedate() }.b(minute)
		 		
		 var postfix = optionbar.register(Stixy.element.$ID("todo_postfix"), "change")
		 postfix.value = "todo-postfix";
		 postfix.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(postfix);
		 postfix.activate = function(){ setSelectElement(this) }.b(postfix)
		 postfix.save = function(){ return this.widget.getTimedate() }.b(postfix)
		 
		
		var remind_only, reminder_switch, remind_at, remind_all, remind_from_list, remind_only;
		
		function remindInit(){
			optionbar.remindSwitcher = Stixy.element.$ID("todo_reminder_switcher");
			optionbar.remindAt = Stixy.element.$ID("todo_remind_at");
			optionbar.remindOnly = Stixy.element.$ID("todo_remind_only");
			optionbar.remindAll = Stixy.element.$ID("todo_remind_all");
			optionbar.remindFromList = Stixy.element.$ID("todo_remind_from_list")
			optionbar.remindList = Stixy.element.$CN("todo-remind-only", optionbar.remindOnly);
			
			reminder_switch = optionbar.register(optionbar.remindSwitcher, "click");
			reminder_switch.command = function(){ 
				if(this.source.checked){
					this.optionbar.widget.remind = true;
					this.announce("checked");
					Stixy.element.removeClassName(Stixy.element.$ID("todo_reminder_panel"), "ghosted");
					Stixy.element.addClassName(this.optionbar.widget.element, "todo-reminder");
				}else{
					this.optionbar.widget.remind = false;
					this.announce("unchecked");
					Stixy.element.addClassName(Stixy.element.$ID("todo_reminder_panel"), "ghosted");
					Stixy.element.removeClassName(this.optionbar.widget.element, "todo-reminder");
				}
			}.b(reminder_switch);
			reminder_switch.save = function(){ 
				return this.widget.getReminder() 
			}.b(reminder_switch)
			reminder_switch.update = function(){
		    this.source.checked = this.widget.remind;
		    this.command();
		  }.b(reminder_switch);
		
			remind_at = optionbar.register(optionbar.remindAt, "change");
			remind_at.command = function(){
				this.widget.remindAt = this.source.value 
			}.b(remind_at);
			remind_at.update = function(){
				for(var i=0; i<this.source.options.length; i++){
					var source = this.source.options[i];
					if(parseInt(source.value) == parseInt(this.widget.remindAt)){
						source.selected = true;
						return
					}
				}
			}.b(remind_at);
			remind_at.activate = function(){ this.source.removeAttribute("disabled") }.b(remind_at);
			remind_at.deactivate = function(){ this.source.setAttribute("disabled", true) }.b(remind_at);
			remind_at.activatedBy(reminder_switch, "checked");
			remind_at.deactivatedBy(reminder_switch, "unchecked");
			remind_at.save = function(){ return this.widget.getReminder() }.b(remind_at);
		
			remind_all = optionbar.register(optionbar.remindAll, (Stixy.browser.substr(0,2)=="ie" ? "click":"change"));
			remind_all.command = function(){ 
				this.optionbar.widget.remindAll = true;
				this.announce("selected");
				remind_from_list.announce("unselected")
			}.b(remind_all);
			remind_all.update = function(){ 
				if(this.widget.remindAll){ 
					this.source.checked = true 
				 	this.announce("selected");
				 	remind_from_list.announce("unselected")
				}
			}.b(remind_all);
			remind_all.activate = function(){ 
				this.source.removeAttribute("disabled");
				if(this.source.checked) this.announce("enabled"); 
			}.b(remind_all);
			remind_all.deactivate = function(){ 
				this.source.setAttribute("disabled", true);
				this.announce("disabled");
			}.b(remind_all);
			remind_all.activatedBy(reminder_switch, "checked");
			remind_all.deactivatedBy(reminder_switch, "unchecked");
			remind_all.save = function(){ return this.widget.getReminder() }.b(remind_all);
				
			remind_from_list = optionbar.register(optionbar.remindFromList, (Stixy.browser.substr(0,2)=="ie" ? "click":"change"));
			remind_from_list.command = function(){ 
				this.widget.remindAll = false;
				this.announce("selected");
			remind_all.announce("unselected")
			}.b(remind_from_list);
			remind_from_list.update = function(){ 
				if(!this.widget.remindAll){ 
					this.source.checked = true;
					this.announce("selected");
					remind_all.announce("unselected")
				}
			}.b(remind_from_list);
			remind_from_list.activate = function(){ 
				this.source.removeAttribute("disabled");
				if(this.source.checked) this.announce("enabled");
			}.b(remind_from_list);
			remind_from_list.deactivate = function(){ 
				this.source.setAttribute("disabled", true);
				this.announce("disabled");
			}.b(remind_from_list);
			remind_from_list.activatedBy(reminder_switch, "checked");
			remind_from_list.deactivatedBy(reminder_switch, "unchecked");
			remind_from_list.save = function(){ return this.widget.getReminder() }.b(remind_from_list);
		
			remind_only = optionbar.register(optionbar.remindList, "change", "remind");
			remind_only.command = function(){
				this.widget.remindOnly = [];
				for(var i=0; i<this.sources.length; i++){
					if(this.sources[i].checked==true) this.widget.remindOnly.push(this.sources[i]);
				}
			}.b(remind_only);
			remind_only.update = function(){
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].checked = false
				}
				for(var i=0; i<this.optionbar.widget.remindOnly.length; i++){
					var source = this.optionbar.widget.remindOnly[i];
					((typeof(source)=="number") ? Stixy.element.$ID("todo_user_" + source) : source).checked = true;
				}
			}.b(remind_only);
			remind_only.activate = function(){ 
				Stixy.element.removeClassName(optionbar.remindOnly, "ghosted");
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].removeAttribute("disabled");
				}
			}.b(remind_only);
			remind_only.deactivate = function(){ 
				Stixy.element.addClassName(optionbar.remindOnly, "ghosted");
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].setAttribute("disabled", true);
				}
			}.b(remind_only);
			remind_only.save = function(){ return this.widget.getReminder() }.b(remind_only);
			remind_only.activatedBy(remind_from_list, "selected");
			remind_only.deactivatedBy(remind_from_list, "unselected");
		}
		
		remindInit();
				
		Stixy.board.listen("beforenavigate", function(){
			optionbar.unregister(reminder_switch);
			optionbar.unregister(remind_at);
			optionbar.unregister(remind_all);
			optionbar.unregister(remind_from_list);
			optionbar.unregister(remind_only);
			optionbar.remindOnly.innerHTML = "";
		});
		Stixy.board.listen("afternavigate", function(e){
			this.request = Stixy.server.connect(null,"/widgets/todo/ajax_user_list/"+e.to, 
 				function(request){ 
 					optionbar.remindOnly.innerHTML = request.responseText;
 					remindInit();
 					this.request = null;
 				}.b(this));
		});
	});
}catch(e){new StixyError(e)}

}
catch(e){
	new StixyError(e);
}

;
 Stixy.browser = 'firefox';
 Stixy.ENV = 'test';