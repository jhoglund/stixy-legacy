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
		    if(source.filters.length > 0){
		      source.filters.item(0).Opacity = value * 100
		    }
  		}else{
  			source.style.opacity = value;
  		}
		},
		getOpacity: function(source){
		  if(source.filters){
  			return (source.filters.length > 0) ? parseFloat((source.filters.item(0).Opacity / 100)||0) : 100;
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