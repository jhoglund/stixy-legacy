// UI			
Stixy.extend(Stixy, {			
	ui: {
		elements: [],
		//scrollPositions: { left:0, top:0 },
		registerElements: function(){
			this.base = document.body;
			this.opt_bar = Stixy.element.$ID("opt_bar");
			this.bopt_bar = Stixy.element.$ID("bopt");
			this.board_list_bar = Stixy.element.$ID("board_list_bar");
			this.bopt_show = Stixy.element.$ID("bopt_show");
			this.bopt_hide = Stixy.element.$ID("bopt_hide");
			this.wopt_show = Stixy.element.$ID("wopt_hide");
			this.wopt_hide = Stixy.element.$ID("wopt_show");
			this.wopt_auto_show = Stixy.element.$ID("wopt_auto_show");
			this.wopt_auto_show_checkbox = Stixy.element.$ID("wopt_auto_show_checkbox");
			this.wopt_auto_show_title = Stixy.element.$ID("wopt_auto_show_title");
			this.tray_show = Stixy.element.$ID("tray_show");
			this.tray_hide = Stixy.element.$ID("tray_hide");
			this.board_list_show = Stixy.element.$ID("board_list_hide");
			this.board_list_hide = Stixy.element.$ID("board_list_show");
			this.canvas = Stixy.element.$ID("stixyboard");
			this.canvas_content = Stixy.element.$ID("canvas_content");
			this.save_button = Stixy.element.$ID("save-state-button");
			this.initElements();
			this.announce('elementsregistred');
		},
		initElements: function(){
			this.registerClassToggle("click", this.bopt_show, this.boptClose.b(this));
			this.registerClassToggle("click", this.bopt_hide, this.boptOpen.b(this));
			this.registerClassToggle("click", this.wopt_hide, this.woptClose.b(this));
			this.registerClassToggle("click", this.wopt_show, this.woptOpen.b(this));
			this.registerClassToggle("click", this.tray_show, this.trayToggle.b(this));
			this.registerClassToggle("click", this.tray_hide, this.trayToggle.b(this));
			this.registerClassToggle("click", this.board_list_show, this.boardListToggle.b(this));
			this.registerClassToggle("click", this.board_list_hide, this.boardListToggle.b(this));
			this.registerClassToggle("click", this.board_list_hide, this.boardListToggle.b(this));
			this.initAllBoardListItems();
			try{
				this.tagFilter = new Stixy.ui.extendedTextField("no-filter","tag_filter");
				this.notification = new Stixy.ui.extendedTextField("no-data","board_notification_box");
				Stixy.events.observe(this.wopt_auto_show_checkbox,"click",this.woptAutoShowToggle.b(this));
			}catch(e){ }
			if(this.save_button){
				Stixy.events.observe(this.save_button,"click",function(){
					if(Stixy.session.isAuthorized() || Stixy.board.isPublic()){
						Stixy.server.update();
					}else{
						Stixy.board.openSignin();
					}
				});
			}
			
		},
		initAllBoardListItems: function(){
			try{
				this.boardListItems = Stixy.element.$CN("board-list-item", this.board_list_bar);
				for(var i=0; i<=this.boardListItems.length; i++){
					this.initBoardListItem(this.boardListItems[i])
				}
			}catch(e){ }
		},
		initBoardListItem: function(item){
			try{
				var id = item.id.match(/\d+/)[0]
				Stixy.events.observe(item, "mouseover", function(element,id,event){
					if(!Stixy.events.related(event,element)){
						this.dragOverItem = element;
						Stixy.ui.announce("mouseoverBoardListItem", element, id);
					}
				}.b(this,item,id));
				Stixy.events.observe(item, "mouseout", function(element,id,event){
					if(!Stixy.events.related(event,element)){
						Stixy.ui.announce("mouseoutBoardListItem", element, id);
						this.dragOverItem = null;
					}
				}.b(this,item,id));
			}catch(e){ }
		},
		pending: function(state){
			Stixy.ui.base[state ? "setAttribute" : "removeAttribute"]("id", "pending")
		},
		storeScrollPositions: function(){
			Stixy.ui.scrollPositions.left = Stixy.ui.canvas.scrollLeft;
			Stixy.ui.scrollPositions.top = Stixy.ui.canvas.scrollTop;
		},
		hasScrolled: function(){
			return	Stixy.ui.canvas.scrollLeft != Stixy.ui.scrollPositions.left ||
							Stixy.ui.canvas.scrollTop != Stixy.ui.scrollPositions.top;
		},
		scrollToPosition: function(position, duration){
			if(!position) { return };
			function scroll(position){
			  if(position.left!==undefined) Stixy.ui.canvas.scrollLeft = position.left ;
  			if(position.top!==undefined) Stixy.ui.canvas.scrollTop = position.top;
			}
			if(duration){
			  // #FIX
			  var duration = Math.min(0.5, Math.max(Math.abs(Stixy.ui.canvas.scrollLeft-position.left), Math.abs(Stixy.ui.canvas.scrollTop-position.top))/100);
			  var animation = new Stixy.effects.Timeline(duration);
    	  var startFrame = animation.setKeyFrame(0, { left:Stixy.ui.canvas.scrollLeft, top:Stixy.ui.canvas.scrollTop });
    	  animation.setKeyFrame(duration, { left:position.left, top:position.top });
    	  startFrame.easeIn = duration*0.20;
    	  startFrame.easeOut = duration*0.20;
    	  animation.onFrame = function(frame){
    	    scroll({left:frame.left, top:frame.top })
    	  }
    	  animation.onFinished = function(frame){
    	    this.announce("scrolltoposition");
    	  }.b(this);
    	  animation.start();
			}else{
			  scroll(position);
			  this.announce("scrolltoposition");
  		}
		},
		saveScroll: function(){
			if(Stixy.ui.canvas && Stixy.ui.saveStates && Stixy.ui.hasScrolled()){
				Stixy.server.connect({attributes:{left:Stixy.ui.canvas.scrollLeft,top:Stixy.ui.canvas.scrollTop}},"/board/board_save_scroll/"+Stixy.board.id);
			}
		},
		registerClassToggle: function(type,source,action){
			if(!source || !action) { return }
			Stixy.events.observe(source,type,action);
			Stixy.events.observe(source,"mouseover",function(event){ Stixy.events.stop(event) });
			Stixy.events.observe(source,"mousedown",function(event){ Stixy.events.stop(event) });
		},
		boptOpen: function(event,save){
			Stixy.events.stop(event)
			if(!Stixy.element.hasClassName(this.base,"wopt-hide")){
				Stixy.element.addClassName(this.base,"wopt-hide");
			}
			Stixy.element.replaceClassName(this.opt_bar,"bopt-panel-closed","bopt-panel-open");
			Stixy.element.replaceClassName(this.base,"bopt-closed","bopt-open");
			Stixy.element.removeClassName(this.base,"bopt-hide");
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_options:1}) };
		},
		boptClose: function(event,save){
			Stixy.events.stop(event)
			Stixy.element.replaceClassName(this.opt_bar,"bopt-panel-open","bopt-panel-closed");
			Stixy.element.replaceClassName(this.base,"bopt-open","bopt-closed");
			Stixy.element.removeClassName(this.base,"wopt-hide");
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_options:0}) };
		},
		woptOpen: function(event){
			Stixy.events.stop(event)
			if(!Stixy.element.hasClassName(this.base,"bopt-hide")){
				Stixy.element.addClassName(this.base,"bopt-hide");
			}
			Stixy.element.removeClassName(this.base,"wopt-hide");
			Stixy.element.removeClassName(this.opt_bar,"wopt-panel-closed");
			Stixy.element.addClassName(this.opt_bar,"wopt-panel-open");
			Stixy.element.removeClassName(this.base,"wopt-closed");
			Stixy.element.addClassName(this.base,"wopt-open");			
		},
		woptClose: function(event){
			Stixy.events.stop(event);
			Stixy.element.removeClassName(this.base,"bopt-hide");
			Stixy.element.removeClassName(this.opt_bar,"wopt-panel-open");
			Stixy.element.addClassName(this.base,"wopt-closed");
			Stixy.element.removeClassName(this.base,"wopt-open");
			Stixy.element.addClassName(this.opt_bar,"wopt-panel-closed");
		},
		woptAutoShowToggle: function(event, state, save){
			Stixy.widgets.Optionbar.setAutoShow(this.wopt_auto_show_checkbox.checked);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_auto_show_wopt:this.wopt_auto_show_checkbox.checked ? 1:0}) };
		},
		boptToggle: function(event, state, save){
			Stixy.events.stop(event);
			if(state==1){ this.boptOpen(save) }
			else{ this.boptClose(save) }
		},
		trayToggle: function(event, state, save){
			Stixy.events.stop(event)
			var result = this.toggle(null,"tray-open","tray-closed",state);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_widget_tray:result}) };
		},
		boardListToggle: function(event, state, save){
			Stixy.events.stop(event)
			var result = this.toggle(null,"board-list-open","board-list-closed",state);
			if(Stixy.ui.saveStates&&save!==false) { this.savePref({pref_ui_board_list:result}) };
		},
		toggle: function(target,show,hide,state){
			var target = target || this.base;
			var open = Stixy.element.hasClassName(target, show);
			if(state==0 || state==undefined && open){
				Stixy.element.replaceClassName(target,show,hide);
			}else{
				Stixy.element.replaceClassName(target,hide,show);
			}
			return open ? 0:1;
		},
		savePref: function(save){
			if(Stixy.session.isAuthorized()) { Stixy.server.connect({attributes:save},"/board/board_user_update_ajax") }
		},
		extendedTextField: function(deactiveClassName,fieldID){
			this.fieldID = fieldID;
			this.deactiveClassName = deactiveClassName;
			this.source = null;
			this.getContent = function(){
				return this.isActive() ? this.source.value : "";
			}
			this.isActive = function(){
				return !Stixy.element.hasClassName(this.source,this.deactiveClassName);
			}
			this.isEmpty = function(){
				return (this.source.value.search(/\S.*/) == -1);
			}
			this.focus = function(){
				if(!this.isActive()){
					this.source.value = "";
				}
				Stixy.element.removeClassName(this.source,this.deactiveClassName)
			}
			this.blur = function(){
				if(this.isEmpty()){
					this.source.value = this.source.title;
					Stixy.element.addClassName(this.source,this.deactiveClassName)
				}
			}
			this.reset = function(){
				this.source = Stixy.element.$ID(this.fieldID);
				if(this.source){
					Stixy.events.observe(this.source, "focus", this.focus.b(this))
					Stixy.events.observe(this.source, "blur", this.blur.b(this))
				}
			}
			this.reset();
			return this;
		},
		inputFeatures: {
			formatDigit: function(value, num){
				var val = value.toString();
				while(val.length < (num||2)){
					val = "0" + val
					break
				}
				return val;
			},
			ControledInput: function(element, max, allowed_keys, reset){
				this.reset = reset;
				var keys = [];
				for(var i=0; i<allowed_keys.length; i++){
					keys[allowed_keys[i][0]] = allowed_keys[i][1];
				}
				function getKey(e){
					return keys[e.keyCode];
				}
				this.arrowKeyDown = function(element, e){
					element.value = this.arrowKeys(element.value, e.keyCode==38);
				}
				this.deleteKeyDown = function(element){
					element.value = this.deleteKey(element.value);
				}
				this.keyDown = null;
				this.beforeSet = function(value){ return value };
				this.afterBlur = function(){ };
				this.arrowKeys = function(){ };
				Stixy.events.observe(element, "focus", function(e){ 
					this.count = 0; 
				}.b(this));
				Stixy.events.observe(element, "blur", function(){ this.afterBlur() }.b(this));
				Stixy.events.observe(element, "keyup", function(e){
					clearInterval(this.keyDown)
				}.b(this));
				Stixy.events.observe(element, "keypress", function(e){
					if(e.keyCode!=9 && e.keyCode!=8){
						Stixy.events.stop(e);
					}
				}.b(this));
				Stixy.events.observe(element, "keydown", function(e){
					if(e.keyCode!=9 && e.keyCode!=8){
						Stixy.events.stop(e);
					}
					code = getKey(e);
					if(code!=undefined){
						if(this.reset && this.count==0 && element.value){
							element.value = element.value.replace(/./g,"0")
						}
						var pos = (max && (this.count < max)) ? (this.count++ % max) : (max ? (max-1) : this.count++);
						var characters = element.value.match(/./g);
						if(characters){
							var members = characters.reverse();
							members.splice(pos,1)
							members.reverse();
							members.push(code);
						}
						var value = members ? members.join("") : code
						var altered_value = this.beforeSet(value, code);
						if(altered_value!==false){
							element.value = altered_value;
						}
					}else{
						if(e.keyCode==38 || e.keyCode==40){
							this.arrowKeyDown(element, e)
							if(!this.keyDown){
								this.keyDown = setInterval(this.arrowKeyDown.b(this, element, e), 200)
							}
						}
					}
				}.b(this));
			},
			NumberInput: function(element, max, start, stop){
				this.element = element
				this.start = start || 0
				var keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				var control 	= new Stixy.ui.inputFeatures.ControledInput(element, max, keys);
				var setValue = function(value, key){
					return (stop && (value > stop)) ? start : (start && (value < start)) ? start : value;
				};
				control.beforeSet = function(value, key){
					return setValue(value, key);
				}.b(this)
				control.arrowKeys = function(value, up){
					return setValue(Number(value) + (up ? +1 : -1));
				}.b(this)
				control.arrowKeys = function(value, up){
					return setValue(Number(value) + (up ? +1 : -1));
				}.b(this)
				control.afterBlur = function(){
					this.element.value = this.element.value.length > 0 ? this.element.value : this.start
				}.b(this);
			},
			DateInput: function(year, month, day){
				this.year = year;
				this.month = month;
				this.day = day;
				var keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				try{
					this.date = new Date(year.value, (month.value-1), day.value);
				}catch(e){
					this.date = new Date.now();
				}
				this.setValues = function(){
					this.year.value = this.date.getFullYear();
					var month = this.date.getMonth()+1;
					this.month.value = (month > 9 ? month : "0"+month);
					var day = this.date.getDate();
					this.day.value = (day > 9 ? day : "0"+day);
				}
				this.updateDate = function(date){
					this.date = date;
					this.setValues();
				}
				var year_control 	= new Stixy.ui.inputFeatures.ControledInput(year, 4, keys);
				var month_control = new Stixy.ui.inputFeatures.ControledInput(month, 2, keys, true);
				var day_control 	= new Stixy.ui.inputFeatures.ControledInput(day, 2, keys, true);
				year_control.afterBlur 	= this.setValues.b(this);
				month_control.afterBlur = this.setValues.b(this);
				day_control.afterBlur 	= this.setValues.b(this);
				year_control.beforeSet = function(value, key){
					this.date.setFullYear(value);
					return Stixy.ui.inputFeatures.formatDigit(value, 4);
				}.b(this)
				month_control.beforeSet = function(value, key){
					var month = (value > 12) ? (key==0 ? 1:key) : value;
					var lastDay = (new Date(this.date.getFullYear(),month,0)).getDate();
					this.date.setFullYear(this.date.getFullYear(), (month-1), Math.min(this.date.getDate(), lastDay));
					return Stixy.ui.inputFeatures.formatDigit(month);
				}.b(this)
				day_control.beforeSet = function(value, key){
					var lastDay = (new Date(this.date.getFullYear(),(this.date.getMonth()+1),0)).getDate();
					var day = (value > lastDay) ? (key==0 ? 1:key) : value;
					this.date.setFullYear(this.date.getFullYear(), this.date.getMonth(), day);
					return Stixy.ui.inputFeatures.formatDigit(day);
				}.b(this)
				year_control.arrowKeys = function(value, up){
					year = (Number(value) + (up ? 1 : -1));
					this.date.setFullYear(year, (this.date.getMonth()), this.date.getDate());
					return Stixy.ui.inputFeatures.formatDigit(year);
				}.b(this)
				month_control.arrowKeys = function(value, up){
					var month = Number(value) + (up ? 1 : -1);
					month = (month > 12) ? 1: month;
					month = (month==0) ? 12: month;
					var lastDay = (new Date(this.date.getFullYear(),month,0)).getDate();
					this.date.setFullYear(this.date.getFullYear(), (month-1), Math.min(this.date.getDate(), lastDay));
					return  Stixy.ui.inputFeatures.formatDigit(month);
				}.b(this)
				day_control.arrowKeys = function(value, up){
					var lastDay = (new Date(this.date.getFullYear(),(this.date.getMonth()+1),0)).getDate();
					var day = Number(value) + (up ? 1 : -1);
					day = (day > lastDay) ? 1: day;
					day = (day==0) ? lastDay: day;
					this.date.setFullYear(this.date.getFullYear(), (this.date.getMonth()), day);
					return  Stixy.ui.inputFeatures.formatDigit(day);
				}.b(this)
			},
			TimeInput: function(hour, minute, postfix){
				this.hour = hour;
				this.minute = minute;
				this.postfix = postfix;
				var number_keys = [[48,0],[49,1],[50,2],[51,3],[52,4],[53,5],[54,6],[55,7],[56,8],[57,9],
				[96,0],[97,1],[98,2],[99,3],[100,4],[101,5],[102,6],[103,7],[104,8],[105,9]]
				
				var hour_control 	= new Stixy.ui.inputFeatures.ControledInput(this.hour, 2, number_keys, true);
				var minute_control = new Stixy.ui.inputFeatures.ControledInput(this.minute, 2, number_keys, true);
				hour_control.afterBlur = function(){
					this.hour.value = Stixy.ui.inputFeatures.formatDigit(this.hour.value.length > 0 ? this.hour.value : 0)
				}.b(this);
				minute_control.afterBlur = function(){
					this.minute.value = Stixy.ui.inputFeatures.formatDigit(this.minute.value.length > 0 ? this.minute.value : 0)
				}.b(this);
				
				this.updateTime = function(date){
					var hour = date.getHours();
					this.hour.value = Stixy.ui.inputFeatures.formatDigit((postfix && (hour > 12)) ? (hour-12) : hour);
					this.minute.value = Stixy.ui.inputFeatures.formatDigit(date.getMinutes());
					if(this.postfix){
						this.postfix.value = (hour > 11) ? "PM" : "AM";
					}
				}.b(this)
				hour_control.beforeSet = function(value, key){
					var time = (value > (postfix ? 12 : 23)) ? (key==0 ? (postfix ? 1 : 0):key) : value < (postfix ? 1 : 0) ? (postfix ? 1 : 0) : value;
					return Stixy.ui.inputFeatures.formatDigit(time);
				}.b(this)
				minute_control.beforeSet = function(value, key){
					var time = (value > 59) ? (key==0 ? 1:key) : value;
					return Stixy.ui.inputFeatures.formatDigit(time);
				}.b(this)
				hour_control.arrowKeys = function(value, up){
					var hour = Number(value) + (up ? 1 : -1);
					hour = (hour > (postfix ? 12 : 23)) ? (postfix ? 1 : 0): hour;
					hour = (hour==(postfix ? 0 : -1)) ? (postfix ? 12 : 23): hour;
					return  Stixy.ui.inputFeatures.formatDigit(hour);
				}.b(this)
				minute_control.arrowKeys = function(value, up){
					var minute = Number(value) + (up ? 1 : -1);
					minute = (minute > 59) ? 0: minute;
					minute = (minute<0) ? 59: minute;
					return  Stixy.ui.inputFeatures.formatDigit(minute);
				}.b(this)

				if(postfix){
					var postfix_control 	= new Stixy.ui.inputFeatures.ControledInput(this.postfix, 2, [[65,"A"],[80,"P"]]);
					postfix_control.beforeSet = function(value, key){
						return key.toUpperCase()=="A" ? "AM" : "PM";
					}.b(this)
					postfix_control.arrowKeys = function(value, up){
						return  (value.search(/p/i) >= 0) ? "AM" : "PM";
					}.b(this)
				}
			},
			GroupToogle: function(switcher, base, ghost_class, elements, on, off){
				this.switcher = switcher;
				this.base = base;
				this.ghost_class = ghost_class;
				this.elements = elements;
				this.on = on;
				this.off = off;
				this.activate = function(update_switch){
					this.announce("activate")
					if(this.elements) Stixy.element.form.setFieldsProperty(this.elements, "disabled", false)
					Stixy.element.removeClassName(this.base, this.ghost_class);
					if(update_switch!==false){ Stixy.element.form.setValue(this.switcher, "checked") };
					if(this.on){ this.on.call(this) }
				}
				this.deactivate = function(update_switch){
					this.announce("deactivate")
					if(this.elements) Stixy.element.form.setFieldsProperty(this.elements, "disabled", "disabled")
					Stixy.element.addClassName(this.base, this.ghost_class);
					if(update_switch!==false){ Stixy.element.form.setValue(this.switcher, false) };
					if(this.off){ this.off.call(this) }
				}
				Stixy.events.observe(this.switcher, "mouseup", function(event){
					Stixy.events.stop(event)
					if(this.switcher.checked==false){
						this.activate(false);
					}else{
						this.deactivate(false);
					}
				}.b(this));
			}
		}
	}
});