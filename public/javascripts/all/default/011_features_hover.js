Stixy.features.Hover = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.mouseEnter = function(event){
    if(!Stixy.events.related(event, this.target)){
      this.announce("enter");
      this.announce("afterenter");
    }
  }
  this.mouseLeave = function(event){
    if(!Stixy.events.related(event, this.target)){
      this.announce("leave");
      this.announce("afterleave");
    }
  }
	this.observe(this.target, "mouseover", this.mouseEnter.be(this));
	this.observe(this.target, "mouseout", this.mouseLeave.be(this));
}