Stixy.features.Remove = function(widget,attributes){
  Stixy.features.Base.call(this, widget, attributes)
  
  this.remove = function(event){
    Stixy.events.stop(event); 
		if(this.widget.locked) return;
    this.announce("beforeremove");
		this.widget.destroy();
  }.b(this)
  this.observe(this.source, "mousedown", this.remove, true);
}
