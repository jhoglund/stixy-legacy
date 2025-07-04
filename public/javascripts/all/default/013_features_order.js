Stixy.features.Order = function (widget,attributes){
	Stixy.features.Base.call(this, widget, attributes)
  this.stay = (attributes["stay"]) ?  (attributes["stay"]==0) ? false : true : false;
  this.reset = attributes["reset"] || false;
  this.index = 0;
  this.changeOrder = function(order,force){
  	if((this.stay && !force)||this.widget.locked||(this.widget.focus&&this.widget.focus.global.areMultipleSelected())) { return }
    this.source.style.zIndex = (order===0) ? --this.global.bottom : ++this.global.top + this.widget.instances.length;
    this.id = (order===0) ? -(new Date().getTime()) : new Date().getTime();
    this.announce("shuffle");
  }
  this.autoMove = function(){
    this.stay = (this.stay) ? false:true;
  }
  this.observe(this.source, "mousedown", this.changeOrder.b(this), true);
}
Stixy.features.Order.prototype.global = new function(){
  this.top = 1000000;
  this.bottom = 1000000;
}