/*  Prototype JavaScript framework, version 1.5.0_rc0
 *  (c) 2005 Sam Stephenson <sam@conio.net>
 *
 *  Prototype is freely distributable under the terms of an MIT-style license.
 *  For details, see the Prototype web site: http://prototype.conio.net/
 *
/*--------------------------------------------------------------------------*/

Object.extend = function(destination, source) {
  for (var property in source) {
    destination[property] = source[property];
  }
  return destination;
}

var Class = {
  create: function() {
    return function() {
      this.initialize.apply(this, arguments);
    }
  }
}

var Event = Event||new Object
var Element = Element||new Object

Function.prototype.closure = function(obj){
  // Init object storage.
  if (!window.__objs){
    window.__objs = [];
    window.__funs = [];
  }

  // For symmetry and clarity.
  var fun = this;

  // Make sure the object has an id and is stored in the object store.
  var objId = obj.__objId;
  if (!objId)
    __objs[objId = obj.__objId = __objs.length] = obj;

  // Make sure the function has an id and is stored in the function store.
  var funId = fun.__funId;
  if (!funId)
    __funs[funId = fun.__funId = __funs.length] = fun;

  // Init closure storage.
  if (!obj.__closures)
    obj.__closures = [];

  // See if we previously created a closure for this object/function pair.
  var closure = obj.__closures[funId];
  if (closure)
    return closure;

  // Clear references to keep them out of the closure scope.
  obj = null;
  fun = null;

  // Create the closure, store in cache and return result.
  return __objs[objId].__closures[funId] = function (){
    return __funs[funId].apply(__objs[objId], arguments);
  };
};

Function.prototype.bind = function() {
  var __method = this, args = $A(arguments), object = args.shift();
  return function() {
    return __method.apply(object, args.concat($A(arguments)));
  }
}

Function.prototype.bindAsEventListener = function(object) {
  var __method = this;
  return function(event) {
    return __method.call(object, event || window.event);
  }
}

var Enumerable = {
  each: function(iterator) {
    var index = 0;
    try {
      this._each(function(value) {
        try {
          iterator(value, index++);
        } catch (e) {
          if (e != $continue) throw e;
        }
      });
    } catch (e) {
      if (e != $break) throw e;
    }
  }
}
var $break    = new Object();
var $continue = new Object();

var $A = function(item) {
  if(!item){
		return [];
	}else if(item instanceof Array){
		return item;
	}else{
    var results = [];
		if(item.length>0)
    	for (var i = 0; i < item.length; i++) results.push(item[i]);
		else
			results.push(item);
    return results;
  }
}


var Ajax = {
  getTransport: function() {
		try{
			return new ActiveXObject('Msxml2.XMLHTTP')
		}catch(e){
			return new XMLHttpRequest()
		}
  },
  activeRequestCount: 0
}
Ajax.Responders = {
  responders: [],

  _each: function(iterator) {
    this.responders._each(iterator);
  },

  register: function(responderToAdd) {
    if (!this.include(responderToAdd))
      this.responders.push(responderToAdd);
  },

  unregister: function(responderToRemove) {
    this.responders = this.responders.without(responderToRemove);
  },

  dispatch: function(callback, request, transport, json) {
    for(var i=0; i<this.responders.length; i++){
			var responder = this.responders[i];
      if (responder[callback] && typeof responder[callback] == 'function') {
        try {
          responder[callback].apply(responder, [request, transport, json]);
        } catch (e) {}
      }
    }
  }
};
Ajax.Base = function() {};
Ajax.Base.prototype = {
  setOptions: function(options) {
    this.options = {
      method:       'post',
      asynchronous: true,
      contentType:  'application/x-www-form-urlencoded',
      parameters:   ''
    }
    Object.extend(this.options, options || {});
  },
  responseIsSuccess: function() {
    return this.transport.status == undefined
        || this.transport.status == 0
        || (this.transport.status >= 200 && this.transport.status < 300);
  },
  responseIsFailure: function() {
    return !this.responseIsSuccess();
  }
}

Ajax.Request = Class.create();
Ajax.Request.Events =
  ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete'];
Ajax.Request.prototype = Object.extend(new Ajax.Base(), {
  initialize: function(url, options) {
    this.transport = Ajax.getTransport();
    this.setOptions(options);
    this.request(url);
  },
  request: function(url) {
		var parameters = this.options.parameters || '';
    if (parameters.length > 0) parameters += '&_=';
    try {
      this.url = url;
      if (this.options.method == 'get' && parameters.length > 0)
        this.url += (this.url.match(/\?/) ? '&' : '?') + parameters;
      this.transport.open(this.options.method, this.url, this.options.asynchronous);
      if (this.options.asynchronous) {
        this.transport.onreadystatechange = this.onStateChange.bind(this);
        setTimeout((function() {this.respondToReadyState(1)}).bind(this), 10);
      }
      this.setRequestHeaders();
      var body = this.options.postBody ? this.options.postBody : parameters;
      this.transport.send(this.options.method == 'post' ? body : null);
    } catch (e) {
			this.dispatchException(e);
    }
  },
  setRequestHeaders: function() {
    var requestHeaders =
      ['X-Requested-With', 'XMLHttpRequest',
       'Accept', 'text/javascript, text/html, application/xml, text/xml, */*'];
    if (this.options.method == 'post') {
      requestHeaders.push('Content-type', this.options.contentType);
      if(this.transport.overrideMimeType) requestHeaders.push('Connection', 'close');
    }
    if(this.options.requestHeaders) requestHeaders.push.apply(requestHeaders, this.options.requestHeaders);
    for (var i = 0; i < requestHeaders.length; i += 2) this.transport.setRequestHeader(requestHeaders[i], requestHeaders[i+1]);
  },
  onStateChange: function() {
    var readyState = this.transport.readyState;
    if (readyState != 1) this.respondToReadyState(this.transport.readyState);
  },
  header: function(name) {
    try {
      return this.transport.getResponseHeader(name);
    } catch (e) {}
  },
  evalJSON: function() {
    try {
      return eval('(' + this.header('X-JSON') + ')');
    } catch (e) {}
  },
  evalResponse: function() {
    try {
      return eval(this.transport.responseText);
    } catch (e) {
      this.dispatchException(e);
    }
  },
  respondToReadyState: function(readyState) {
    var event = Ajax.Request.Events[readyState];
    var transport = this.transport, json = this.evalJSON();
    if (event == 'Complete') {
      try {
        (this.options['on' + this.transport.status]
         || this.options['on' + (this.responseIsSuccess() ? 'Success' : 'Failure')]
         || Prototype.emptyFunction)(transport, json);
      } catch (e) {
        this.dispatchException(e);
      }
      if ((this.header('Content-type') || '').match(/^text\/javascript/i))
        this.evalResponse();
    }
    try {
      (this.options['on' + event] || function(){})(transport, json);
      Ajax.Responders.dispatch('on' + event, this, transport, json);
    } catch (e) {
      this.dispatchException(e);
    }
    /* Avoid memory leak in MSIE: clean up the oncomplete event handler */
    if (event == 'Complete')
      this.transport.onreadystatechange = function(){};
  },
  dispatchException: function(exception) {
    (this.options.onException || function(){})(this, exception);
    Ajax.Responders.dispatch('onException', this, exception);
  }
});

Ajax.Updater = Class.create();

Object.extend(Object.extend(Ajax.Updater.prototype, Ajax.Request.prototype), {
  initialize: function(container, url, options) {
    this.containers = {
      success: container.success ? $(container.success) : $(container),
      failure: container.failure ? $(container.failure) :
        (container.success ? null : $(container))
    }

    this.transport = Ajax.getTransport();
    this.setOptions(options);

    var onComplete = this.options.onComplete || function(){};
    this.options.onComplete = (function(transport, object) {
      this.updateContent();
      onComplete(transport, object);
    }).bind(this);

    this.request(url);
  },

  updateContent: function() {
    var receiver = this.responseIsSuccess() ?
      this.containers.success : this.containers.failure;
    var response = this.transport.responseText;

    if (!this.options.evalScripts)
      response = response.stripScripts();

    if (receiver) {
      if (this.options.insertion) {
        new this.options.insertion(receiver, response);
      } else {
        Element.update(receiver, response);
      }
    }

    if (this.responseIsSuccess()) {
      if (this.onComplete)
        setTimeout(this.onComplete.bind(this), 10);
    }
  }
});

function $(element) {
  return (typeof(element)=="string") ? document.getElementById(element) : element;
}

document.getElementsByClassName = function(className, parentElement) {
  var children = parentElement.getElementsByTagName('*'), elements = [];
	for(var i=0; i<children.length; i++){
		if(children[i].className.match(new RegExp("(^|\\s)" + className + "(\\s|$)"))){
			elements.push(children[i]);
		}
	}
  return elements;
}

Object.extend(Event, {
  element: function(event) {
    return event.target || event.srcElement;
  },
  isLeftClick: function(event) {
    return (((event.which) && (event.which == 1)) || ((event.button) && (event.button == 1)));
  },
  pointerX: function(event) {
    return event.pageX || (event.clientX + (document.documentElement.scrollLeft || document.body.scrollLeft));
  },
  pointerY: function(event) {
    return event.pageY || (event.clientY + (document.documentElement.scrollTop || document.body.scrollTop));
  },
  stop: function(event) {
		if(event.preventDefault) {
      event.preventDefault();
      event.stopPropagation();
    } else {
      event.returnValue = false;
      event.cancelBubble = true;
    }
  },
  before_unload_filters: false,
	observers: false,
  _observeAndCache: function(element, name, observer, useCapture) {
    if (!this.observers) this.observers = [];
    if (element.addEventListener) {
			this.observers.push([element, name, observer, useCapture]);
    	element.addEventListener(name, observer, useCapture);
		} else if (element.attachEvent) {
      if(element==window && name=="mouseup") element = document;
			this.observers.push([element, name, observer, useCapture]);
      element.attachEvent('on' + name, observer.closure(element));
    }
  },
  unloadCache: function() {
		for (var i = 0; i < Event.before_unload_filters.length; i++) {
			Event.before_unload_filters[i]();
		}
    if (!Event.observers) return;
    for (var i = 0; i < Event.observers.length; i++) {
      Event.stopObserving.apply(this, Event.observers[i]);
      Event.observers[i][0] = null;
    }
    Event.observers = false;
  },
	beforeUnload: function(fun){
		this.before_unload_filters = this.before_unload_filters || [];
		this.before_unload_filters.push(fun)
	},
  observe: function(element, name, observer, useCapture) {
    useCapture = useCapture || false;
    if (name == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || element.attachEvent)) name = 'keydown';
    this._observeAndCache(element, name, observer, useCapture);
  },
  stopObserving: function(element, name, observer, useCapture) {
    useCapture = useCapture || false;
		if (name == 'keypress' && (navigator.appVersion.match(/Konqueror|Safari|KHTML/) || element.detachEvent)) name = 'keydown';
    if (element.removeEventListener) {
      element.removeEventListener(name, observer, useCapture);
    } else if (element.detachEvent) {
			if(element==window && name=="mouseup") element = document;
      element.detachEvent('on' + name, observer.closure(element));
    }
  }
});

Event.observe(window, 'unload', Event.unloadCache, false);