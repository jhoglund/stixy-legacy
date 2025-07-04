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
    var json = Stixy.JSON.decode(unescape('<%= URI.escape({ :replace => { :popup_content => render( :partial => "/shared/popup/non_supported_feature").gsub(/\n/,"") } }.to_json) %>'))
    Stixy.extend(json.replace, Stixy.JSON.decode(unescape('<%= URI.escape({ :popup_buttons => render( :partial => "/shared/popup/close_button").gsub(/\n/,"") }.to_json) %>')))
    Stixy.popup.populate(json, 500,300)
    return false;
  }
  return true;
}