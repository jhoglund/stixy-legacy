Stixy.features.Resize = function(widget, attributes){
  Stixy.features.Base.call(this, widget, attributes)
  this.proportional = attributes["proportional"] || false;
  this.horizontal = (attributes["horizontal"]===false) ? false:true;
  this.vertical = (attributes["vertical"]===false) ? false:true;
  this.minWidth = attributes["minwidth"]   || 0;
  this.minHeight = attributes["minheight"] || 0;
  this.maxWidth = attributes["maxwidth"]   || 10000;
  this.maxHeight = attributes["maxheight"] || 10000;
  this.updated = false;
  this.originalAspectRatio = function(){
    this.originalWidth = this.target.scrollWidth;
    this.originalHeight = this.target.scrollHeight;
    this.aspectRatio = this.originalHeight / this.originalWidth;
  }
  this.startResize = function(event){
    if(this.widget.locked) return;
    this.announce("beforeresize");
    this.originalAspectRatio();
    this.offsetX = event.clientX;
    this.offsetY = event.clientY;
    this.observe(document, "mouseup",  this.stopResize.be(this));
    this.observe(document, "mousemove",  this.resize.be(this));
		try{
  		document.body.style.setProperty("-khtml-user-select","none","important");
		}catch(e){}
	}
  this.resize = function(event){
    Stixy.events.stop(event);
    this.updated = true;
    this.calculateSize(event.clientX, event.clientY);
		this.snapToGrid();
    this.updateSize()
    this.announce("resize");
  }
  this.stopResize = function(){
		this.stopObserving(document, "mouseup",  this.stopResize);
    this.stopObserving(document, "mousemove",  this.resize);
    this.announce("afterresize");
    this.updated = false;
  	try{
			document.body.style.removeProperty("-khtml-user-select");
		}catch(e){}
	}
  this.calculateSize = function(startX,startY){
    if(this.proportional) { var propertionalSize = ((startX - this.offsetX) +  (startY - this.offsetY)) / 2 }
    var newWidth =  (this.proportional) ? this.originalWidth + Math.round(propertionalSize / this.aspectRatio)
                                        : this.originalWidth + startX - this.offsetX;
    var newHeight = (this.proportional) ? this.originalHeight + Math.round(propertionalSize)
                                        : this.originalHeight + startY - this.offsetY;
    this.x = (newWidth  < this.minWidth)  ? this.minWidth  : (newWidth  > this.maxWidth)  ? this.maxWidth  : newWidth;
    this.y = (newHeight < this.minHeight) ? this.minHeight : (newHeight > this.maxHeight) ? this.maxHeight : newHeight;
  }
  this.updateSize = function(){
		if(this.horizontal) { this.target.style.width = this.x + "px" }
    if(this.vertical) { this.target.style.height = this.y + "px" }
  }
  this.updateAspectRatio = function(x,y){
		this.x = x;
		this.y = y;
		this.updateSize();
    this.widget.save({width:parseInt(this.widget.element.style.width),height:parseInt(this.widget.element.style.height)})
  }
  this.observe(this.source, "mousedown",  this.startResize.be(this));
}
Stixy.features.Resize.prototype = new Stixy.features.common.Size;