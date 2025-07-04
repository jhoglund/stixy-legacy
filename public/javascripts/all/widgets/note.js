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
      if(Stixy.ua.gecko){
        this.text.moveSelectionTo(this.text.source.lastChild)
      }
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
	    object.activatedBy(function(){ return this.widget ? this.widget.text : new Object }.b(object), "gotfocus");
	    object.deactivatedBy(function(){ return this.widget ? this.widget.text : new Object }.b(object), "lostfocus");
	    object.updatedWhen(function(){ return this.widget ? this.widget.text : new Object }.b(object), "textselected");
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