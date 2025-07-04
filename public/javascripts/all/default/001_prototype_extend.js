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
Object.prototype.merge = function(o){
  function m(l, r) {
    r.eachProperty(function(i) {
      try{
        if(r[i].constructor==Object ){
          l[i] = m(l[i]||{}, r[i]);
        }else{
          l[i] = r[i];
        }
      }catch(e){}
    });
    return l;
  }
  m(this,o)
}
Object.prototype.merge.__prototype_extension = true;
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