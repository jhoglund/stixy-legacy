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
	Stixy.widgets.Optionbar.frame.window = Stixy.element.$ID("widget_options_frame");
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
	// =========================================================================
  // = # TODO: From old js file. This needs to be refactored in a better way =
  // =========================================================================
  if(document.activeElement===undefined){
    var initActiveElement = function(element){
      Stixy.events.observe(element, "focus", function(e){
       document.activeElement = Stixy.events.element(e);
      });
      Stixy.events.observe(element, "blur", function(e){
        if(document.activeElement == Stixy.events.element(e)){
          delete document.activeElement;
        }
      });
    }
    var options = this.optionbar.panel.getElementsByTagName("*");
    var length = options.length;
    for(var i=0; i<length; i++){
      initActiveElement(options[i]);
    }
    Stixy.events.observe(document.body, "DOMNodeInserted", function(e){
      initActiveElement(Stixy.events.element(e));
    })
  }
  
	//Stixy.events.observe(this.optionbar.panel, 'mousedown', function(e){
	//  //Stixy.events.stop(e);
	//  console.log(123)
	//})
	//this.optionbar.panel = Stixy.widgets.Optionbar.frame.window.doc.getElementById(element_id);
	return this.optionbar;
}