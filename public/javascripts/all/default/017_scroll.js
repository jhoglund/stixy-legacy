// Scroll
// This feature is special written for scroll of canvas. It probably has to be rewritten 
Stixy.features.Scroll = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.offsetX = 0;
  this.offsetY = 0;
	this.left = 0;
  this.top = 0;
  this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.startMove = function(event){
    this.announce("beforescroll", event);
    Stixy.events.stop(event);
		this.offsetX = event.clientX + this.target.scrollLeft;
    this.offsetY = event.clientY + this.target.scrollTop;
    Stixy.events.observe(document, "mousemove",  this.move.b(this));
    Stixy.events.observe(document, "mouseup",  this.stopMove.b(this));
  }
  this.move = function(event){
    this.announce("scroll");
    this.updated = true;
    Stixy.events.stop(event);
		this.x = event.clientX - this.offsetX;
    this.y = event.clientY - this.offsetY;
    var pointer = {x:this.x,y:this.y};
    if(this.lastPointer && (this.lastPointer.x == pointer.x && this.lastPointer.y == pointer.y)) return;
    this.lastPointer = pointer;
		this.target.scrollLeft = -pointer.x;
		this.target.scrollTop = -pointer.y;

  }
  this.stopMove = function(event){
    Stixy.events.stopObserving(document, "mousemove",  this.move.b(this));
    Stixy.events.stopObserving(document, "mouseup",  this.stopMove.b(this));
    this.announce("afterscroll");
    this.updated = false;
  }
  Stixy.events.observe(this.source, "mousedown",  this.startMove.b(this), true);
	return this;
}