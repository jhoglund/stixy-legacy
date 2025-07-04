Stixy.extend(Stixy, {
	html: {
		clear: function(element){
			Stixy.element.$ID(element).innerHTML = "";
		},
		replace: function(parent, content){
		  var element = (parent.substr ? Stixy.element.$ID(parent) : parent);
		  if(element){
		    element.innerHTML = content;
		  }
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