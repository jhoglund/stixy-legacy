Stixy.features.Scroll = function(widget, attributes){
  Stixy.features.Base.call(this, widget, attributes)
	this.target = attributes.target;
	this.up    = attributes.up    || Stixy.element.$CN("scrollbar-up", 	 	widget.element)[0];
	this.down  = attributes.down  || Stixy.element.$CN("scrollbar-down",  widget.element)[0];
	this.left	 = attributes.left	|| Stixy.element.$CN("scrollbar-left", 	widget.element)[0];
	this.right = attributes.right || Stixy.element.$CN("scrollbar-right", widget.element)[0];
	this.states = { x:false, y:false }
	this.accelerator = 1;
	this.scrollPositions = {}
	function axes(f){
		for(var i=0; i<2; i++) f((i==0 ? "x" : "y"), (i==0));
	}
	this.getOffsetPosition = function(x){
		//return this.target[(x ? "offsetLeft" : "offsetTop")];
		return parseInt(this.target.style[(x ? "left" : "top")]) || 0
	}
	this.getOffsetSize = function(x,type){
		return this.target[type + (x ? "Width":"Height")]
	}
	this.updateClassName = function(state,direction,className){
		this.states[direction] = state;
		Stixy.element[state ? "addClassName":"removeClassName"](widget.element,(className||("scrollbar-"+direction+"-on")));
	}
	this.setState = function(state,className){
		axes(function(direction,isHorizontal){
			this.updateClassName(state,direction,className);
		}.b(this));
	}
	this.autoState = function(className){
		axes(function(direction,isHorizontal){
			var scrolled = (this.getOffsetSize(isHorizontal,"scroll") > this.getOffsetSize(isHorizontal,"offset")) || (this.getOffsetPosition(isHorizontal) < 0);
			if(this.states[direction] != scrolled){
				this.updateClassName(scrolled,direction,className);
			}
		}.b(this));
	}
	this.getScrollPosition = function(axes){
		return -this.getOffsetPosition(axes!="y");
	}
	this.setScrollPosition = function(x,y){
		this.initScrollPositions();
		this.scrollToPosition(x,y)
	}
	this.scrollToPosition = function(x,y){
		if(x) this.target.style.left = -x +"px";
		if(y) this.target.style.top = -y +"px";
		this.target.style.clip = "rect("+
			Math.min(-this.target.offsetTop, this.scrollPositions.minYStart) +"px "+ this.scrollPositions.xEnd +"px "+ this.scrollPositions.yEnd +"px "+
			Math.min(-this.target.offsetLeft, this.scrollPositions.minXStart) +"px)";
	}
	this.initScrollPositions = function(){
		this.scrollPositions.minYStart = this.target.scrollHeight+this.target.offsetTop;
		this.scrollPositions.minXStart = this.target.scrollWidth+this.target.offsetLeft;
		this.scrollPositions.minYEnd = this.target.offsetHeight+this.target.offsetTop-this.target.scrollHeight;
		this.scrollPositions.minXEnd = this.target.offsetWidth+this.target.offsetLeft-this.target.scrollWidth;
		this.scrollPositions.yEnd = this.target.scrollHeight;
		this.scrollPositions.xEnd = this.target.scrollWidth;
	}
	this.scroll = function(step,vertical,element,e){
		Stixy.events.stop(e);
		this.initScrollPositions();
		var scroller = function(){
			var yStart = Math.min((this.getOffsetPosition(vertical)+(step*this.accelerator)),0);
			var xStart = Math.max((this.getOffsetPosition(vertical)+(step*this.accelerator)),(vertical ? this.scrollPositions.minXEnd:this.scrollPositions.minYEnd));
			var start = (element==this.up||element==this.left) ? -yStart:-xStart;
			this.scrollToPosition((vertical ? start : false),vertical ? false : start)
		}.b(this)
		scroller();
		this.scrollTimer = setInterval(scroller,10)
		this.clearScroll = function(){ 
			clearInterval(this.scrollTimer);
			Stixy.element.removeClassName(element,activeClassName);
			Stixy.events.stopObserving(document, "mouseup", this.clearScroll);
		}.b(this);
		Stixy.events.observe(document, "mouseup", this.clearScroll);
		var activeClassName = element.className+"-active";
		Stixy.element.addClassName(element,activeClassName);
	}
	Stixy.events.observe(this.left, "mousedown", this.scroll.b(this,1,true,this.left));
	Stixy.events.observe(this.right, "mousedown", this.scroll.b(this,-1,true,this.right));
	Stixy.events.observe(this.up, "mousedown", this.scroll.b(this,1,false,this.up));
	Stixy.events.observe(this.down, "mousedown", this.scroll.b(this,-1,false,this.down));
}
