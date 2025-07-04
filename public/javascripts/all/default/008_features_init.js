Stixy.extend(Stixy, {
	features: {
		Base: function(widget, attributes){
		  this.widget = widget;
			this.attachedEvents = [];
		  this.target = attributes["target"] || attributes["source"] || null;
		  this.source = attributes["source"] || attributes["target"] || null;
			this.observe = function(target, eventName, func, phase){
				phase = phase||false
				this.attachedEvents.push([target, eventName, func, phase]);
				Stixy.events.observe(target, eventName, func, phase);
			}
			this.stopObserving = function(target, eventName, func, phase){
				phase = phase||false
				for(var i=0; i<this.attachedEvents.length; i++){
					var ev = this.attachedEvents[i];
					if(ev[0]==target && ev[1]==eventName && ev[2]==func && ev[3]==phase) { this.attachedEvents.splice(i,1) }
				}
				Stixy.events.stopObserving(target, eventName, func, phase);
			}
			this.remove = function(test){
				for(var i=0; i<this.attachedEvents.length; i++){
					var ev = this.attachedEvents[i];
					Stixy.events.stopObserving(ev[0], ev[1], ev[2], ev[3]);
					this.cashed_events = {};
				}
				delete this.events;
				this.events = [];
			}
			if(!this.target && !this.source) { return null }
		},
		common: {}
	}
});

Stixy.features.common.Size = function(){
	this.grid = 10;
	this.snap = false;
	this.snapToGrid = function(){
		if((!this.snap && (!Stixy.events.activeKeys[16]))||(this.snap && (Stixy.events.activeKeys[16]))) { return }
		this.x = Math.round(this.x/this.grid) * this.grid;
		this.y = Math.round(this.y/this.grid) * this.grid;
	}
}