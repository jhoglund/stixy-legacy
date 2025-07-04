Stixy.widgets.Todo = function(element_id,attributes){
	this.constructor = Stixy.widgets.Todo;
	this.value = element_id;
	this.attributes = attributes || {};
  this.type = 4;
	this.remind =    	this.attributes.remind			||	false;
	this.remindAll = 	(this.attributes.remindAll == undefined) ? true : this.attributes.remindAll;
	this.remindOnly = this.attributes.remindOnly	||	[];
	this.remindAt = 	this.attributes.remindAt		||	null;
	
	this.getReminder = function(){
		if(this.optionbar.remindSwitcher.checked == false){
			return { reminder: {remind_at:0, remind_users:0} }
		}else{
			var users = { 0: (this.optionbar.remindAll.checked==true) ? 1 : 0 };
			for(var i=0; i<this.optionbar.remindList.length; i++){
				var inputElement = this.optionbar.remindList[i];
				users[inputElement.value] = (inputElement.checked) ? 1 : 0;
			}
			return { reminder: { 
					remind_at: this.optionbar.remindAt.value,
					remind_users: users
				}
			}
		}
	}
	this.getTimedate = function(){
		var dates = [];
		var classNames = ["todo-month","todo-day","todo-year","todo-hour","todo-minute","todo-postfix"];
		for(var i=0; i<classNames.length; i++){
			dates.push(Stixy.element.$CN(classNames[i], this.element)[0].innerHTML);
		}
		return  {time: dates[0]+" "+dates[1]+" "+dates[2]+" "+dates[3]+":"+dates[4]+" "+dates[5] }
	}
	this.activate = function(){
	  Stixy.widgets.Base.call(this)
	  this.initialize("todo",element_id,this.attributes);
		this.listen("drop", function(){
	    this.text.source.focus(); // First we need to set the focus to the element, or the anchorNode will be the body element
      this.text.focus();
      if(Stixy.ua.gecko){
        this.text.moveSelectionTo(this.text.source.lastChild)
      }
			this.save(this.getTimedate());
			this.save({text:{value:this.text.getSource.b(this.text)}});
	  }.b(this));
		this.active = true;
	}
	this.activate();
}
Stixy.widgets.Todo.prototype = new Stixy.widgets.Base;

// OPTIONBAR
try{
	Stixy.widgets.Optionbar.frame.listen("ready",function(){
		var optionbar = Stixy.widgets.Todo.prototype.loadOptionbar("wopt-todo");
		var todoClassNames = ["todo-year","todo-month","todo-dayname","todo-day"];
		

		
		function getDateArray(element){
			var dates = [];
			for(var i=0; i<todoClassNames.length; i++){
				dates.push(Stixy.element.$CN(todoClassNames[i], element)[0].innerHTML)
			}
			return dates;
    }

    function getParsedDate(element){
    	var date_array = getDateArray(element);
    	return date_array[0] + "-" + date_array[1] + "-" + date_array[2] + "-" + date_array[3]
    }

    function setSelectElement(tool){
			for(var i=0; i<tool.source.options.length; i++){
				var source = tool.source.options[i];
				if(source.value == Stixy.element.$CN(tool.value, tool.widget.element)[0].innerHTML){
					source.selected = true;
					return source;
				}
			}
    }
		
		function getActiveOption(selectelement){
			return selectelement.options[selectelement.selectedIndex];
		}
		
  	var calendar, nav_prev, nav_next;

 		function calendarInit(){
			calendar = optionbar.register(Stixy.element.$A(Stixy.element.$ID("todo_calendar").getElementsByTagName("td")));
			calendar.command = function(){
				var str = calendar.source.id.split("-");
				for(var i=0; i<todoClassNames.length; i++){
					Stixy.element.$CN(todoClassNames[i], calendar.optionbar.widget.element)[0].innerHTML = str[i];
				}
				if(calendar.selected) Stixy.element.removeClassName(calendar.selected,"calendar-selected-day");
				calendar.selected = calendar.source;
				Stixy.element.addClassName(calendar.selected,"calendar-selected-day");
			};
 			calendar.save = function(){ return calendar.optionbar.widget.getTimedate() }

			nav_prev = Stixy.element.$ID("todo_calendar_nav_previuos")
			nav_next = Stixy.element.$ID("todo_calendar_nav_next")
			Stixy.events.observe(nav_prev,"click", loadCalendar.b(this,nav_prev.title));
			Stixy.events.observe(nav_next,"click", loadCalendar.b(this,nav_next.title));
			return calendar;
 		}

		function calendarReset(){
		  calendar = calendarInit();
  	  if(!calendar.optionbar.widget) return;
		  calendar.active = true;
  	  var str_date = getParsedDate(calendar.optionbar.widget.element);
		  for(var i=0; i<calendar.sources.length; i++){
		  	var source = calendar.sources[i];
		  	if(source.id==str_date){
		  		calendar.selected = source;
		  		Stixy.element.addClassName(calendar.selected,"calendar-selected-day")
		  		return calendar;
		  	}
		  }
  	}
		
		function loadCalendar(date){
		 	optionbar.unregister(calendar);
			Stixy.events.stopObserving(nav_prev,"click",loadCalendar);
			Stixy.events.stopObserving(nav_next,"click",loadCalendar);
			if(calendar.request) return;
	 		Stixy.element.$ID('todo_progress_indicator').style.display = "";
			var date_array = getDateArray(calendar.optionbar.widget.element);
	 		calendar.request = Stixy.server.connect(null,"/widgets/todo/ajax_calendar?calendar_date="+date, 
	 			function(request){ 
	 				Stixy.element.$ID("todo_calendar").innerHTML = request.responseText;
	 				calendarReset();
			  	calendar.request = null;
	 			});
		}
		
		calendarInit();
		
		calendar.activate = function(){
 			if(this.request) return;
 			Stixy.element.$ID('todo_progress_indicator').style.display = "";
 			var date_array = getDateArray(this.widget.element);
			this.request = Stixy.server.connect(null,"/widgets/todo/ajax_calendar?year=" + date_array[0] + "&month_name=" + date_array[1], 
 				function(request){ 
 					Stixy.element.$ID("todo_calendar").innerHTML = request.responseText;
 					calendarReset();
 					this.request = null;
 				}.b(this) 
 			);
 		}.b(calendar);
		

		var todo_view = optionbar.register([Stixy.element.$ID("todo_full_view"),Stixy.element.$ID("todo_compact_view")], "click","todo_view")
		todo_view.command = function(){ 
		  if(this.source.value=="full"){
				Stixy.element.removeClassName(this.widget.element, "todo-compact");
			}else{	
				Stixy.element.addClassName(this.widget.element, "todo-compact");
			}
		}.b(todo_view);
		todo_view.activate = function(){
			if(Stixy.element.hasClassName(this.widget.element, "todo-compact")){
				this.sources[1].checked = true;
			}else{
				this.sources[0].checked = true;
			}
		}.b(todo_view)
		todo_view.save = function(){
			return {
				style:{view:{value:(Stixy.element.hasClassName(this.widget.element, "compact")) ? 1:0}}
			}
		}.b(todo_view)

		 var hour = optionbar.register(Stixy.element.$ID("todo_hour"), "change")
		 hour.value = "todo-hour";
		 hour.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(hour);
		 hour.activate = function(){ setSelectElement(this) }.b(hour)
		 hour.save = function(){ return this.widget.getTimedate() }.b(hour)
		 		
		 var minute = optionbar.register(Stixy.element.$ID("todo_minute"), "change")
		 minute.value = "todo-minute";
		 minute.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(minute);
		 minute.activate = function(){ setSelectElement(this) }.b(minute)
		 minute.save = function(){ return this.widget.getTimedate() }.b(minute)
		 		
		 var postfix = optionbar.register(Stixy.element.$ID("todo_postfix"), "change")
		 postfix.value = "todo-postfix";
		 postfix.command = function(){ Stixy.element.$CN(this.value, this.widget.element)[0].innerHTML = this.source.value }.b(postfix);
		 postfix.activate = function(){ setSelectElement(this) }.b(postfix)
		 postfix.save = function(){ return this.widget.getTimedate() }.b(postfix)
		 
		
		var remind_only, reminder_switch, remind_at, remind_all, remind_from_list, remind_only;
		
		function remindInit(){
			optionbar.remindSwitcher = Stixy.element.$ID("todo_reminder_switcher");
			optionbar.remindAt = Stixy.element.$ID("todo_remind_at");
			optionbar.remindOnly = Stixy.element.$ID("todo_remind_only");
			optionbar.remindAll = Stixy.element.$ID("todo_remind_all");
			optionbar.remindFromList = Stixy.element.$ID("todo_remind_from_list")
			optionbar.remindList = Stixy.element.$CN("todo-remind-only", optionbar.remindOnly);
			
			reminder_switch = optionbar.register(optionbar.remindSwitcher, "click");
			reminder_switch.command = function(){ 
				if(this.source.checked){
					this.optionbar.widget.remind = true;
					this.announce("checked");
					Stixy.element.removeClassName(Stixy.element.$ID("todo_reminder_panel"), "ghosted");
					Stixy.element.addClassName(this.optionbar.widget.element, "todo-reminder");
				}else{
					this.optionbar.widget.remind = false;
					this.announce("unchecked");
					Stixy.element.addClassName(Stixy.element.$ID("todo_reminder_panel"), "ghosted");
					Stixy.element.removeClassName(this.optionbar.widget.element, "todo-reminder");
				}
			}.b(reminder_switch);
			reminder_switch.save = function(){ 
				return this.widget.getReminder() 
			}.b(reminder_switch)
			reminder_switch.update = function(){
		    this.source.checked = this.widget.remind;
		    this.command();
		  }.b(reminder_switch);
		
			remind_at = optionbar.register(optionbar.remindAt, "change");
			remind_at.command = function(){
				this.widget.remindAt = this.source.value 
			}.b(remind_at);
			remind_at.update = function(){
				for(var i=0; i<this.source.options.length; i++){
					var source = this.source.options[i];
					if(parseInt(source.value) == parseInt(this.widget.remindAt)){
						source.selected = true;
						return
					}
				}
			}.b(remind_at);
			remind_at.activate = function(){ this.source.removeAttribute("disabled") }.b(remind_at);
			remind_at.deactivate = function(){ this.source.setAttribute("disabled", true) }.b(remind_at);
			remind_at.activatedBy(reminder_switch, "checked");
			remind_at.deactivatedBy(reminder_switch, "unchecked");
			remind_at.save = function(){ return this.widget.getReminder() }.b(remind_at);
		
			remind_all = optionbar.register(optionbar.remindAll, (Stixy.browser.substr(0,2)=="ie" ? "click":"change"));
			remind_all.command = function(){ 
				this.optionbar.widget.remindAll = true;
				this.announce("selected");
				remind_from_list.announce("unselected")
			}.b(remind_all);
			remind_all.update = function(){ 
				if(this.widget.remindAll){ 
					this.source.checked = true 
				 	this.announce("selected");
				 	remind_from_list.announce("unselected")
				}
			}.b(remind_all);
			remind_all.activate = function(){ 
				this.source.removeAttribute("disabled");
				if(this.source.checked) this.announce("enabled"); 
			}.b(remind_all);
			remind_all.deactivate = function(){ 
				this.source.setAttribute("disabled", true);
				this.announce("disabled");
			}.b(remind_all);
			remind_all.activatedBy(reminder_switch, "checked");
			remind_all.deactivatedBy(reminder_switch, "unchecked");
			remind_all.save = function(){ return this.widget.getReminder() }.b(remind_all);
				
			remind_from_list = optionbar.register(optionbar.remindFromList, (Stixy.browser.substr(0,2)=="ie" ? "click":"change"));
			remind_from_list.command = function(){ 
				this.widget.remindAll = false;
				this.announce("selected");
			remind_all.announce("unselected")
			}.b(remind_from_list);
			remind_from_list.update = function(){ 
				if(!this.widget.remindAll){ 
					this.source.checked = true;
					this.announce("selected");
					remind_all.announce("unselected")
				}
			}.b(remind_from_list);
			remind_from_list.activate = function(){ 
				this.source.removeAttribute("disabled");
				if(this.source.checked) this.announce("enabled");
			}.b(remind_from_list);
			remind_from_list.deactivate = function(){ 
				this.source.setAttribute("disabled", true);
				this.announce("disabled");
			}.b(remind_from_list);
			remind_from_list.activatedBy(reminder_switch, "checked");
			remind_from_list.deactivatedBy(reminder_switch, "unchecked");
			remind_from_list.save = function(){ return this.widget.getReminder() }.b(remind_from_list);
		
			remind_only = optionbar.register(optionbar.remindList, "change", "remind");
			remind_only.command = function(){
				this.widget.remindOnly = [];
				for(var i=0; i<this.sources.length; i++){
					if(this.sources[i].checked==true) this.widget.remindOnly.push(this.sources[i]);
				}
			}.b(remind_only);
			remind_only.update = function(){
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].checked = false
				}
				for(var i=0; i<this.optionbar.widget.remindOnly.length; i++){
					var source = this.optionbar.widget.remindOnly[i];
					((typeof(source)=="number") ? Stixy.element.$ID("todo_user_" + source) : source).checked = true;
				}
			}.b(remind_only);
			remind_only.activate = function(){ 
				Stixy.element.removeClassName(optionbar.remindOnly, "ghosted");
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].removeAttribute("disabled");
				}
			}.b(remind_only);
			remind_only.deactivate = function(){ 
				Stixy.element.addClassName(optionbar.remindOnly, "ghosted");
				for(var i=0; i<this.sources.length; i++){
					this.sources[i].setAttribute("disabled", true);
				}
			}.b(remind_only);
			remind_only.save = function(){ return this.widget.getReminder() }.b(remind_only);
			remind_only.activatedBy(remind_from_list, "selected");
			remind_only.deactivatedBy(remind_from_list, "unselected");
			
		}
		
		remindInit();
		
		// Link tool

    // Click event doesn't work in IE when selection is collapsed. 
    // The parent element of the range will be BODY independent of where the click was initiated.
    // A workaround we're using mousedown for IE instead of click 
    var textlink = optionbar.register([Stixy.element.$ID("link_text_todo")],(Stixy.ua.ie ? 'mousedown' : 'click'),"insert-link");
    textlink.command = function(){
  	  if(Stixy.ua.unless(/Firefox\/2/)){
        this.widget.text.openEditLinkPopup();
      }
    }.b(textlink)
    textlink.activatedBy(function(){ return this.widget ? this.widget.text : new Object }.b(textlink), "gotfocus");
    textlink.deactivatedBy(function(){ return this.widget ? this.widget.text : new Object }.b(textlink), "lostfocus");
    textlink.updatedWhen(function(){ return this.widget ? this.widget.text : new Object }.b(textlink), "textselected");
    
    textlink.activate = function(){ 
      Stixy.element.removeClassName(this.source.parentNode.parentNode, "deactivated");
      Stixy.element.removeClassName(this.sources[0], "ghosted") 
    }
    textlink.deactivate = function(){ 
      Stixy.element.addClassName(this.source.parentNode.parentNode, "deactivated");
      Stixy.element.addClassName(this.sources[0], "ghosted") 
    }
    textlink.save = function(){ return {text:{value:this.optionbar.widget.text.getSource()}}}
    
				
		Stixy.board.listen("beforenavigate", function(){
			optionbar.unregister(reminder_switch);
			optionbar.unregister(remind_at);
			optionbar.unregister(remind_all);
			optionbar.unregister(remind_from_list);
			optionbar.unregister(remind_only);
			optionbar.remindOnly.innerHTML = "";
		});
		Stixy.board.listen("afternavigate", function(e){
			this.request = Stixy.server.connect(null,"/widgets/todo/ajax_user_list/"+e.to, 
 				function(request){ 
 					optionbar.remindOnly.innerHTML = request.responseText;
 					remindInit();
 					this.request = null;
 				}.b(this));
		});
	});
}catch(e){new StixyError(e)}