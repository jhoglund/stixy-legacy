// Always test when code is updated:
// Scroll stixyboard horizontal and vertical and move widgets and add new widgets

Stixy.features.Move = function(widget, attributes){
	Stixy.features.Base.call(this, widget, attributes)
	this.offsetX = 0;
  this.offsetY = 0;
	this.left = this.target.offsetLeft;
  this.top = this.target.offsetTop;
	this.startX = 0;
	this.startY = 0;
	this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.start = attributes["start"]   || -100000;
  this.stop = attributes["stop"] || 100000;
  this.minX = attributes["minX"] || 100000;
  this.minY = attributes["minY"] || 100000;
  this.maxX = attributes["maxX"] || 100000;
  this.maxY = attributes["maxY"] || 100000;
  this.locked = this.stay = this.updated = this.inside = this.outside = false;
  this.droparea = attributes["droparea"] || null;
  this.setLock = function(lock){
    this.locked = lock || false;
  }
	this.setX = function(value){
		this.target.style.left = value + "px"
	}
  this.setY = function(value){
		this.target.style.top = value + "px"
	}
	this.reset = function(){
		this.setX(this.startX);
		this.setY(this.startY);
	}
	this.startMove = function(event){
		Stixy.events.stop(event);
    if(this.stay||this.locked||this.widget.locked) return;
		this.startX = this.target.offsetLeft;
		this.startY = this.target.offsetTop;
		this.offsetX = (event.clientX - this.startX);
    this.offsetY = (event.clientY - this.startY);
    this.announce("beforemove", event);
		this.observe(document, "mousemove",  this.move.be(this));
    this.observe(document, "mouseup",  this.stopMove.be(this));
  }
  this.move = function(event){
		if(this.locked) { return }
		this.announce("move");
    this.updated = true;
		Stixy.events.stop(event);
    if(this.droparea){
      if(event.clientX > this.droparea.left && event.clientX < this.droparea.right && event.clientY > this.droparea.top && event.clientY < this.droparea.bottom ){
				if(!this.inside) { this.announce("enterdroparea") }
				this.inside = true;
				this.announce("insidedroparea");
      }else{
				if(this.inside) { this.announce("leavedroparea") }
				this.inside = false;
				this.announce("outsidedroparea");
      }
    }
    this.x = event.clientX - this.offsetX;
    this.y = event.clientY - this.offsetY;
		this.snapToGrid();
    var pointer = [this.x,this.y];
    if(this.lastPointer && (this.lastPointer[0] == pointer[0] && this.lastPointer[1] == pointer[1])) { return }
    this.lastPointer = pointer;
		// Set the pointers so, for example, a widget can't be placed outside of a Stixyboard.
		pointer[0] = (((pointer[0]+this.minX)>0) ? pointer[0] : -this.minX);
		pointer[1] = (((pointer[1]+this.minY)>0) ? pointer[1] : -this.minY);
		if(this.horizontal && (pointer[0]>this.start) && (pointer[0]<this.stop)) { this.setX(pointer[0]) }
    if(this.vertical && (pointer[1]>this.start) && (pointer[1]<this.stop)) { this.setY(pointer[1]) }
  }
  this.stopMove = function(event){
    this.stopObserving(document, "mousemove",  this.move);
    this.stopObserving(document, "mouseup",  this.stopMove);
    this.announce("aftermove");
    this.updated = false;
  }
  this.observe(this.source, "mousedown",  this.startMove.be(this));
}
Stixy.features.Move.prototype = new Stixy.features.common.Size;