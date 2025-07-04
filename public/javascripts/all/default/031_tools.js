// Tools			
Stixy.extend(Stixy, {
	tools: {
		cashed_tools: [],
		addToToolbar: function(){
			for(var i=0; i<arguments.length;i++){
				var widget = arguments[i][0];
				var element = Stixy.element.$ID(arguments[i][1]);
				this.cashed_tools.push(new function(){
		      this.widget = widget;
		      this.element = element;
		      this.small = element.cloneNode(true);
		      this.small.style.display = "none";
					this.element.parentNode.parentNode.appendChild(this.small);
		      this.smallOffsetX = 0;
		      this.smallOffsetY = 0;
					this.droparea = {
		        element: function(){
							return Stixy.ui.canvas;
						},
		        offsetHeight: 165, left: 0, top: 0, right: 0, bottom: 0, offsetWidth: 0, offsetLeft: 0, offsetTop: 0
		      }
					this.createWidget = function(){
						var large = Stixy.element.$CN("widget",this.element)[0].cloneNode(true);
		        large.id = Stixy.tempID.get();
						large.style.zIndex = 100000000;
		        large.style.display = "none";
		    		this.element.parentNode.appendChild(large);
						this.large = large;
						return large;
					}
					this.createWidget();
					this.move = new Stixy.features.Move(this, {source:this.element,target:this.small,droparea:this.droparea});
					this.move.listen("beforemove", function(event){
						this.droparea.bottom = document.body.clientHeight - this.droparea.offsetHeight;
		        this.droparea.right = document.body.clientWidth - this.droparea.offsetWidth;
		      	this.droparea.element().appendChild(this.large);
						this.move.offsetX = event.clientX - this.element.parentNode.offsetLeft;
				    this.move.offsetY = event.clientY - this.element.parentNode.offsetTop;
		      	this.small.style.left = this.move.offsetX + "px";
						this.small.style.top = this.move.offsetY + "px";
						this.small.style.display = "block";
					}.b(this));
		      this.move.listen("aftermove", function(){
		        this.small.style.display = "none";
		        this.small.style.left = "0px";
		        this.small.style.top = "0px";
		        if(this.move.inside){
		          var widget = new this.widget(this.large.id)
							widget.announce("drop");
							this.createWidget();
							Stixy.widgets.addWidget(widget)
		        }
						this.move.target = this.small;
						this.move.inside = false;
		      }.b(this));
		      this.move.listen("enterdroparea", function(){
						this.large.style.visibility = "hidden";
		        this.large.style.display = "block";
		        this.smallOffsetX = this.move.offsetX;
		        this.smallOffsetY = this.move.offsetY;
						this.move.offsetX = (this.large.scrollWidth/2)-this.droparea.element().scrollLeft+this.droparea.element().offsetLeft; 
		        this.move.offsetY = (this.large.scrollHeight/2)-this.droparea.element().scrollTop;
						this.move.minX = this.large.clientWidth-10; 
		        this.move.minY = this.large.clientHeight-70;
		        this.large.style.visibility = "visible";
		        this.small.style.display = "none";
		        this.move.target = this.large;
		      }.b(this));
		      this.move.listen("leavedroparea", function(){
		        this.large.style.display = "none";
		        this.small.style.display = "block";
						this.move.offsetX = this.smallOffsetX;
		        this.move.offsetY = this.smallOffsetY;
		        this.move.target = this.small;
		      }.b(this));
				});
			}
		}
	}
});