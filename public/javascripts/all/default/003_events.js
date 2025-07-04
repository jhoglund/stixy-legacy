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
	    if(this.observers){
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
  		}
	    this.observers = {};
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
		  try{
		    if(n == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || e.detachEvent)) { n = 'keydown' }
  			if(e && e.removeEventListener){
  				if(o){ e.removeEventListener(n, o, c) };
  	    }else if(e && e.detachEvent){
  				if(e==window && n=="mouseup") { e = document }
  	      if(o){ e.detachEvent('on' + n, o) };
  	    }
		  }catch(error){}
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
// Prevent memory leak in IE.
// We do this for IE only, since we don't want to use unload events if not necerssary since it prevents the page from being cached by browsers
if(Stixy.ua.ie){
  Stixy.events.observe(window, 'unload', Stixy.events.unloadCache.b(Stixy.events));
}