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