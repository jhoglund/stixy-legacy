Stixy.calendar = new function(){
		
	this.resetCalendar = function(){
		this.toggleCalendarNewPanel(false);
		this.resetCalendarEntry();
	}
	this.resetCalendarEntry = function(){ }
	this.init = function(){
		this.calendar_entry_panel = Stixy.element.$ID("calendar_entry_panel");
		this.edit_panel = Stixy.element.$ID("edit_entry_panel");
		this.calendar_new_panel = Stixy.element.$ID("new_entry_panel");
		this.todo_new_panel = Stixy.element.$ID("new_todo_panel");
		this.calendar_base = Stixy.element.$ID("calendar");
		this.calendar_list_panel = Stixy.element.$ID("calendar_list");
		this.activity_list = Stixy.element.$ID("activity_list");
		this.activity_list_default = Stixy.element.$ID("activity_list_default");
		this.todo_list = Stixy.element.$ID("todo_list");
		this.new_panels = {calendar_entry:{},calendar_todo:{}};
		this.edit_panels = {calendar_entry:{},calendar_todo:{}};
		this.new_panels.calendar_entry.elements = Stixy.element.form.elementsToObject(document.forms['calendar_new_entry_form'], true).calendar_entry;
		this.new_panels.calendar_todo.elements = Stixy.element.form.elementsToObject(document.forms['calendar_new_todo_form'], true).calendar_todo;
		this.initCalendar(0);
		this.initCalendarEntryPanel(this.calendar_new_panel, this.new_panels.calendar_entry);
		this.initTodoPanel(this.todo_new_panel, this.new_panels.calendar_todo);
		try{
			this.initCalendarEntryPanel(this.edit_panel, this.edit_panel);
		}catch(e){}
		try{
			this.initTodoPanel(this.edit_panel, this.edit_panel);
		}catch(e){}
		
		Stixy.events.observe(document.forms['calendar_new_entry_form'], "submit", function(e){
			Stixy.events.stop(e);
			this.createEntry('calendar_new_entry_form');
		}.b(this));
		
		Stixy.events.observe(document.forms['calendar_new_todo_form'], "submit", function(e){
			Stixy.events.stop(e);
			this.createEntry('calendar_new_entry_form');
		}.b(this));
		
		Stixy.events.observe(document.forms['calendar_edit_form'], "submit", function(e){
			Stixy.events.stop(e);
			this.editEntry();
		}.b(this));
		
	}
	
	// Update the form fields of the New Calender Entry panel
	this.updateCalendarEntryPanel = function(){
		var elements = this.new_panels.calendar_entry.elements;
		this.new_panels.calendar_entry.recurring_toggler.deactivate();
		this.new_panels.calendar_entry.notify_toggler.deactivate();
		this.new_panels.calendar_entry.location_toggler.deactivate();
		this.new_panels.calendar_entry.note_toggler.deactivate();
		var selected_date = (this.selected_calendar ? this.selected_calendar : this.calendar_month).getAttribute("sx:date").split("-");
		selected_date[1] = (Number(selected_date[1]) - 1);
		var date = new Date(selected_date[0],selected_date[1],selected_date[2]);
		date.setHours((new Date).getHours())
		date.setTime(date.getTime()+(1000*60*60),0,0)
		this.new_panels.calendar_entry.start_time_controler.updateTime(date);
		this.new_panels.calendar_entry.start_date_controler.updateDate(date);
		date.setTime(date.getTime()+(1000*60*60),0,0)
		this.new_panels.calendar_entry.stop_time_controler.updateTime(date);
		this.new_panels.calendar_entry.stop_date_controler.updateDate(date);
		//elements.subject.focus();
		Stixy.element.form.setValue(elements.subject, "");
		Stixy.element.form.setValue(elements.location, "");
		Stixy.element.form.setValue(elements.note, "");
	}
	
	// Update the form fields of the New Todo panel
	this.updateTodoEntryPanel = function(){
		var elements = this.new_panels.calendar_todo.elements;
		this.new_panels.calendar_todo.due_toggler.deactivate();
		this.new_panels.calendar_todo.notify_toggler.deactivate();
		this.new_panels.calendar_todo.due_toggler.deactivate();
		this.new_panels.calendar_todo.note_toggler.deactivate();
		var selected_date = (this.selected_calendar ? this.selected_calendar : this.calendar_month).getAttribute("sx:date").split("-");
		selected_date[1] = (Number(selected_date[1]) - 1);
		var due_date = new Date(selected_date[0],selected_date[1],selected_date[2]);
		due_date.setHours((new Date).getHours())
		due_date.setTime(due_date.getTime()+(1000*60*60),0,0)
		this.new_panels.calendar_todo.due_time_controler.updateTime(due_date);
		this.new_panels.calendar_todo.due_date_controler.updateDate(due_date);
		Stixy.element.form.setValue(elements.completed, false);
		Stixy.element.form.setValue(elements.priority, 0);
		Stixy.element.form.setValue(elements.subject, "");
		Stixy.element.form.setValue(elements.note, "");
	}
	function initNotify(root, element){
		element.notify = Stixy.element.$nsID("notify", "sx", root);
		element.notify_status = Stixy.element.$nsID("status", "sx", element.notify);
		element.notify_value = Stixy.element.$nsID("value", "sx", element.notify);
 		element.notify_unit = Stixy.element.$nsID("unit", "sx", element.notify);
		element.notify_controls = Stixy.element.$nsID("controls", "sx", element.notify);
		element.notify_toggler = new Stixy.ui.inputFeatures.GroupToogle(element.notify_status,element.notify_controls, "ghosted", [element.notify_value, element.notify_unit]);
		element.notify_value_controler = new Stixy.ui.inputFeatures.NumberInput(element.notify_value, 3, 1, null)
		element.notify_toggler.listen("activate", function(){
			Stixy.element.removeClassName(element.notify, "controls-hide")
		})
		element.notify_toggler.listen("deactivate", function(){
			Stixy.element.addClassName(element.notify, "controls-hide")
		})
	}
	function initNote(root, element){
		element.note = Stixy.element.$nsID("note", "sx", root);
		element.note_status = Stixy.element.$nsID("note-switcher", "sx", root);
		element.note_toggler = new Stixy.ui.inputFeatures.GroupToogle(element.note_status,element.note, "controls-hide");
	}
	this.initCalendarEntryPanel = function(root, element){
		initNotify(root, element);
		initNote(root, element);
		element.recurring = Stixy.element.$nsID("recurring", "sx", root);
		element.recurring_status = Stixy.element.$nsID("status", "sx", element.recurring);
		element.recurring_status_frequency = Stixy.element.$nsID("frequency", "sx", element.recurring);
		element.recurring_status_unit = Stixy.element.$nsID("unit", "sx", element.recurring);
		element.recurring_controls = Stixy.element.$nsID("controls", "sx", element.recurring);
		element.start_date = Stixy.element.$nsTag("start-date","sx",root)
		element.stop_date = Stixy.element.$nsTag("stop-date","sx",root)
		element.start_time = Stixy.element.$nsTag("start-time","sx",root)
		element.stop_time = Stixy.element.$nsTag("stop-time","sx",root)
		element.start_date_controler = new Stixy.ui.inputFeatures.DateInput(Stixy.element.$nsID("year","sx", element.start_date), Stixy.element.$nsID("month","sx", element.start_date), Stixy.element.$nsID("day","sx", element.start_date))
		element.stop_date_controler = new Stixy.ui.inputFeatures.DateInput(Stixy.element.$nsID("year","sx", element.stop_date), Stixy.element.$nsID("month","sx", element.stop_date), Stixy.element.$nsID("day","sx", element.stop_date))
		element.start_time_controler = new Stixy.ui.inputFeatures.TimeInput(Stixy.element.$nsID("hour","sx", element.start_time), Stixy.element.$nsID("minute","sx", element.start_time), Stixy.element.$nsID("postfix","sx", element.start_time))
		element.stop_time_controler = new Stixy.ui.inputFeatures.TimeInput(Stixy.element.$nsID("hour","sx", element.stop_time), Stixy.element.$nsID("minute","sx", element.stop_time), Stixy.element.$nsID("postfix","sx", element.stop_time))
		element.recurring_toggler = new Stixy.ui.inputFeatures.GroupToogle(element.recurring_status,element.recurring_controls, "ghosted", [element.recurring_status_frequency, element.recurring_status_unit]);
		element.recurring_value_controler = new Stixy.ui.inputFeatures.NumberInput(element.recurring_status_frequency, 3, 1, null)
		element.location = Stixy.element.$nsID("location", "sx", root);
		element.location_status = Stixy.element.$nsID("location-switcher", "sx", root);
		element.location_toggler = new Stixy.ui.inputFeatures.GroupToogle(element.location_status,element.location, "controls-hide");
		
		element.recurring_toggler.listen("activate", function(){
			Stixy.element.removeClassName(element.recurring, "controls-hide")
		})
		element.recurring_toggler.listen("deactivate", function(){
			Stixy.element.addClassName(element.recurring, "controls-hide")
		})
	}
	
	this.initTodoPanel = function(root, element){
		//console.log(root)
		initNotify(root, element);
		initNote(root, element);
		element.due = Stixy.element.$nsID("due", "sx", root, true);
		element.due_status = Stixy.element.$nsID("status", "sx", element.due);
		element.due_controls = Stixy.element.$nsID("controls", "sx", element.due);
		element.due_date = Stixy.element.$nsTag("date","sx",root)
		element.due_time = Stixy.element.$nsTag("time","sx",root)
		var year = Stixy.element.$nsID("year","sx", element.due_date);
		var month = Stixy.element.$nsID("month","sx", element.due_date);
		var day = Stixy.element.$nsID("day","sx", element.due_date);
		var hour = Stixy.element.$nsID("hour","sx", element.due_time);
		var minute = Stixy.element.$nsID("minute","sx", element.due_time);
		var postfix = Stixy.element.$nsID("postfix","sx", element.due_time);
		element.due_date_controler = new Stixy.ui.inputFeatures.DateInput(year, month, day);
		element.due_time_controler = new Stixy.ui.inputFeatures.TimeInput(hour, minute, postfix);
		element.due_toggler = new Stixy.ui.inputFeatures.GroupToogle(element.due_status,element.due_controls, "ghosted", [year, month, day, hour, minute, postfix]);
		element.due_toggler.listen("activate", function(){
			Stixy.element.removeClassName(element.due, "controls-hide")
		})
		element.due_toggler.listen("deactivate", function(){
			Stixy.element.addClassName(element.due, "controls-hide")
		})
	}
	
	// Init the edit calendar after the content has been replaced after a item has been edited 
	this.initCalendar = function(id){
		this.calendar_month = Stixy.element.$ID("calendar_month");
		this.boxes = this.calendar_base.getElementsByTagName("TD");
		this.entries = {}
		var all_entries = Stixy.element.$nsTags("entry", "sx", document.body);
		
		// Populate the Entries object with all entries in the page
		for(var i=0; i<all_entries.length; i++){
			var entry = all_entries[i];
			var name = "_" + entry.getAttribute("sx:entry-id")
			this.entries[name] = this.entries[name] || [];
			this.entries[name].push(entry);
		}
		this.activity_panel = Stixy.element.$ID("activity_list");
		this.selected_calendar = Stixy.element.$nsID("selected-day", "sx", this.calendar_base);
		this.selected_activity_list = Stixy.element.$nsID("selected-day", "sx", this.activity_list);
		if(this.selected_calendar && this.selected_calendar.push){
			this.selected_calendar = this.selected_calendar[0];
		}
		if(this.selected_activity_list && this.selected_activity_list.push){
			this.selected_activity_list = this.selected_activity_list[0];
		}
		for(var i=0; i<this.boxes.length; i++){
			clickInBox(this.boxes[i]);
		}
		this.entries.eachProperty(function(id,siblings){
			this.withElement = function(source,targets){
				clickOnEntry(source, targets, id)
				rollOverAnEntry(source, targets)
				rollOutOffAnEntry(source, targets)
			}
			for(var i=0; i<siblings.length; i++){
				this.withElement(siblings[i],siblings)
			}
		}.b(this));
		var todos = Stixy.element.$nsTags("todo-checkbox", "sx", document.body);
		for(var i=0; i<todos.length; i++){
			clickOnTodo(todos[i].getElementsByTagName("input")[0], function(source){
				return function(){ Stixy.element[source.getElementsByTagName("input")[0].checked ? "addClassName" : "removeClassName"](source, "todo-list-completed") }
			}(todos[i]));
		}
	}
	this.newCalendarEntry = function(){
		this.updateCalendarEntryPanel();
		this.panelOpen(this.calendar_new_panel);
	}
	this.newTodo = function(){
		this.updateTodoEntryPanel();
		this.panelOpen(this.todo_new_panel);
	}
	this.getSelectedDay = function(){
		return (this.selected_calendar) ? this.selected_calendar.title : '0';
	}
	this.getSelectedCalendar = function(){
		return this.calendar_month.getAttribute("sx:date");
	}
	this.panelClose = function(){
		this.togglePanel(this.calendar_entry_panel, false);
		this.togglePanel(this.edit_panel, false);
		this.togglePanel(this.calendar_new_panel, false);
		this.togglePanel(this.todo_new_panel, false);
		this.togglePanel(this.calendar_list_panel, true);
	}
	this.panelOpen = function(panel){
		if(this.active_panel){
			this.togglePanel(this.active_panel, false);
		}
		this.active_panel = panel;
		this.togglePanel(this.calendar_list_panel, false);
		this.togglePanel(panel, true);
		this.togglePanel(this.calendar_entry_panel, true);
	}
	this.openWidget = function(board_id, widget_id, focus){
		Stixy.calendar.toggleEntryPanelPending(true);
		this.board.listen('load', function(){
			this.widgets.getWidget(widget_id).scrollIntoView(focus, true); 
			this.popup.close();
		}.b(this));
		this.board.navigate(board_id);
	}
	this.togglePanel = function(panel, state){ Stixy.element[(state ? "addClassName" : "removeClassName")](panel, "calendar-panel-show") },
	this.toggleTodoListPending = function(state){ Stixy.element[(state ? "addClassName" : "removeClassName")](this.todo_list, "todo-list-pending") },
	this.toggleEntryPanelPending = function(state){ Stixy.element[(state ? "addClassName" : "removeClassName")](this.calendar_entry_panel, "calendar-panel-pending") },
	this.clearCompletedTodos = function(){
		this.toggleTodoListPending(true)
		Stixy.server.json(null, "/calendar/clear_completed/", function(){
			this.toggleTodoListPending(false)
		}.b(this))
	}
	this.createEntry = function(form_name){
		var results = Stixy.element.form.elementsToObject(document.forms[form_name])
		delete results.popup
		this.sendEntry(results, "/calendar/create")
	}
	this.editEntry = function(){
		var results = Stixy.element.form.elementsToObject(document.forms['calendar_edit_form'])
		delete results.popup
		this.sendEntry(results, "/calendar/edit")
	}
	this.removeEntry = function(){
		var results = Stixy.element.form.elementsToObject(document.forms['calendar_edit_form'])
		this.sendEntry(results, "/calendar/remove")
	}
	this.navigateCalendar = function(date){
		Stixy.element.addClassName(Stixy.element.$ID("calendar_navigation_pending"), "stixy-calendar-pending")
		this.sendEntry({ date:date }, "/calendar/index")
	}
	this.sendEntry = function(results, uri, after_return){
		var body =  { body: Stixy.extend(results, { selected_day:this.getSelectedDay(), selected_calendar:this.getSelectedCalendar() } ) };
		this.toggleEntryPanelPending(true)
		Stixy.server.json(Stixy.XML.fromObject(body), uri, function(){
			Stixy.calendar.panelClose();
			this.toggleEntryPanelPending(false);
		}.b(this))
	}
	
	// Click outside an entry, inside a table cell. Both in the calendar, aswell as in the panel (Calendar entry and todo item)
	var clickInBox = function(source){
		Stixy.events.observe(source, "click", function(source,event){
			Stixy.events.stop(event)
			if(this.selected_calendar){ Stixy.element.removeClassName(this.selected_calendar, "calendar-selected-day") }
			this.selected_calendar = source;
			Stixy.element.addClassName(this.selected_calendar, "calendar-selected-day");
			if(this.dblClickDelay){
				this.dblClickFlag = true;
				this.newCalendarEntry();
				clearTimeout(this.dblClickDelay);
				this.dblClickDelay = null;
			}else{
				this.dblClickDelay = setTimeout(function(){
					this.panelClose();
					this.dblClickFlag = false;
					this.dblClickDelay = null;
				}.b(this), 300);
			}
			if(this.selected_activity_list){ Stixy.element.removeClassName(this.selected_activity_list, "activity-list-selected-day") }
			this.selected_activity_list = Stixy.element.$ID("activity_list_" + source.title) || this.activity_list_default;
			Stixy.element.addClassName(this.selected_activity_list, "activity-list-selected-day");
		}.b(this,source), false);
	}.b(this);
	
	// Click on an entry. Both in the calendar, aswell as in the panel (Calendar entry and todo item)
	var clickOnEntry = function(source, targets, id){
		Stixy.events.observe(source, "click", function(id, event){
			Stixy.events.stop(event)
			this.active_id = id.replace(/\D/g,"");
			if(this.sources){
				for(var n=0; n<this.sources.length; n++) Stixy.element.removeClassName(this.sources[n], "calendar-entry-selected");
			}
			this.sources = targets;
			for(var n=0; n<targets.length; n++) Stixy.element.addClassName(targets[n], "calendar-entry-selected");
			this.panelOpen(this.edit_panel);
			var entry = { body: { entry_type: { value: source.getAttribute("sx:entry-type") } } };
			entry.body[entry.body.entry_type.value] = { id: this.active_id };
			this.toggleEntryPanelPending(true);
			Stixy.server.json(entry, ("/calendar/show/"+source.title), function(request){
				this.toggleEntryPanelPending(false);
			}.b(this))
		}.b(this, id), false);
	}.b(this);
	
	// Rollover on an entry. Both in the calendar, aswell as in the panel (Calendar entry and todo item)
	var rollOverAnEntry = function(source, targets){
		Stixy.events.observe(source, "mouseover", function(element,event){
			if(!Stixy.events.related(event,element)){
				for(var n=0; n<targets.length; n++){
					if(targets[n]) Stixy.element.addClassName(targets[n], "calendar-entry-rollover");
				}
			}
		}.b(this,source),true);
	}.b(this);
	
	// Rollout off an entry. Both in the calendar, aswell as in the panel (Calendar entry and todo item)
	var rollOutOffAnEntry = function(source, targets){
		Stixy.events.observe(source, "mouseout", function(element,event){
			if(!Stixy.events.related(event,element)){
				for(var n=0; n<targets.length; n++) Stixy.element.removeClassName(targets[n], "calendar-entry-rollover");
			}
		}.b(this,source),true);
	}.b(this);
	
	// Click on an checkbox in the todo list
	var clickOnTodo = function(source, before, after){
		Stixy.events.observe(source, "click", function(event){
			Stixy.events.stop(event);
		}.b(this), true);
		Stixy.events.observe(source, "mouseup", function(event){
			Stixy.events.stop(event);
			Stixy.element.form.setValue(source, Stixy.element.form.getValue(source)=="0")
			var entry = { body: { entry_type: { value: source.getAttribute("sx:entry-type") } } };
			entry.body[entry.body.entry_type.value] = { id: source.getAttribute("sx:entry-id"), completed: Stixy.element.form.getValue(source) };
			this.toggleTodoListPending(true);
			if(before) before()
			Stixy.server.json(entry, "/calendar/edit", function(request){
				this.toggleTodoListPending(false);
				if(after) after()
			}.b(this));
		}.b(this));
	}.b(this);
		
}

Stixy.listen("ready",function(){
	this.init();
}.b(Stixy.calendar));


