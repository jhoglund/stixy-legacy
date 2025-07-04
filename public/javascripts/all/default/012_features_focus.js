Stixy.features.Focus = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes);
	this.hasFocus = false;
	this.giveFocus = function(event){
		if(this.hasFocus && (event && event.shiftKey)){ 
			this.resetFocus() 
			return;
		}
		if(this.hasFocus) { return }
		if(!(event && event.shiftKey)){ this.global.announce("resetfocus") }
		this.global.listen("resetfocus", this.resetFocus.b(this));
		this.global.listen("singlefocus", this.singlefocus.b(this));
		this.hasFocus = true;
		this.global.multipleSelected(true);
		this.announce("gotfocus", this.global.areMultipleSelected());
		this.global.announce("newfocus", this.widget);
		this.observe(Stixy.ui.canvas, "mousedown", this.looseFocus.b(this), false);
	}
	this.singlefocus = function(){
		this.announce("singlefocus");
	}
	this.resetFocus = function(){
		if(this.hasFocus){
			this.deactivate();
    	this.delight();
    	this.stopFocus();
			this.global.multipleSelected(false);
		}
	}
	this.looseFocus = function(event){
		Stixy.events.stop(event);
		if(!Stixy.events.contained(event,this.widget.element) && !event.shiftKey){ 
			this.stopFocus() 
			this.global.resetMultipleSelect();
		}
	}
	this.stopFocus = function(){
		this.stopObserving(Stixy.ui.canvas, "mousedown", this.looseFocus.b(this), false);
		this.global.unlisten("resetfocus", this.resetFocus.b(this));
		this.global.unlisten("singlefocus", this.singlefocus.b(this));
		this.hasFocus = false;
		this.announce("lostfocus");
  }
  this.activate = function(event){
		this.isActive = true;
		this.announce("activated");
  }
	this.deactivate = function(event){
		if(this.isActive){
			this.isActive = false;
	    this.announce("deactivated");
	  }
	}
  this.highlight = function(event){
		this.observe(Stixy.ui.canvas, "mousedown", this.looseHighlight.b(this), true);
		this.global.resetHighlight();
		this.global.setWidget(this.widget);
		this.isHighlighted = true;
		this.announce("highlighted");
  }
	this.delight = function(event){
    if(this.isHighlighted){
			this.stopObserving(Stixy.ui.canvas, "mousedown", this.looseHighlight, true);
			this.isHighlighted = false;
	    this.announce("delighted");
  	}
	}
  this.looseHighlight = function(event){
		this.delight(event)
	}
	this.observe(this.source, "mousedown", this.giveFocus.b(this), true);
}
Stixy.features.Focus.prototype.global = new function(){
	this.multipleSelected = function(add){
		this.widgetCount += add ? 1 : -1;
		if(this.widgetCount==1){
			this.announce("singlefocus");
		}
	}
	this.areMultipleSelected = function(){
		return this.widgetCount > 1;
	}
  this.resetMultipleSelect = function(){
		this.widgetCount = 0;
	}
	this.resetMultipleSelect();
  this.resetHighlight = function(){
    if(this.widget){
      if(this.widget.focus.isActive) this.widget.focus.deactivate();
      if(this.widget.focus.isHighlighted) this.widget.focus.delight();
      this.resetWidget();
    }
  }
  this.setWidget = function(widget){
		this.widget = widget;
	}
  this.resetWidget = function(){
		this.widget = null;
	}
}