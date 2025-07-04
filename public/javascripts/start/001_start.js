try {

	var StixyError = function(e,label){
		this.message = e.message;
		this.lineNumber = e.line || e.lineNumber;
		if(!this.lineNumber && e.stack) // Chrome
	    this.lineNumber = (/\d+:\d+$/.exec(e.stack) || [0])[0];
	  if(!this.lineNumber && e.number) // Set linenumber to IE error code (http://msdn.microsoft.com/en-us/library/6bby3x2e(VS.85).aspx and http://msdn.microsoft.com/en-us/library/1dk3k160(VS.85).aspx)
	    this.lineNumber = (e.number & 0xFFFF);
	  this.label = label;
	  this.name = e.name;
	  this.stack = e.stack;
		this.version = STIXY_FILE_GENERATED_AT;
		this.errors.push(this);
		if(STIXY_ENV=="production"){
			this.post(this.message, this.name, this.lineNumber, this.label, this.version)
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
			this.server.send("<body><version>"+this.version+"</version><message>"+this.message+"</message><name>"+this.name+"</name><lineNumber>"+this.lineNumber+"</lineNumber><stack>" + this.stack + "</stack><label>"+(this.label||"")+"</label><line>"+this.lineNumber+"</line></body>");
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