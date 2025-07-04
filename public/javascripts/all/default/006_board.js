Stixy.extend(Stixy, {
	board: {
		id: null,
		inProgress: false,
		getID: function(){
			return this.id;
		},
		isPublic: function(){
		  // This needs to be looked into. Is it secure? Can it ba hacked?
		  return /http\:\/\/.*?stixy.com\/guest\//.test(document.location.href);
		},
		not_authorized: function (){
			if(Stixy.session.isAuthorized() || !Stixy.server.ques || (Stixy.server.ques.storage.length == 0)) return false;
			Stixy.popup.open("/public/new_stixyboard?popup=true");
			return true;
		},
		navigate: function(id, token, save_changes){
			this.announce("beforenavigate", {from:Stixy.board.id,to:id})
			this.announce("unload")
			this.listen("afterupdate", (function(oid){
				this.announce("afternavigate", {from:oid,to:id})
			}.b(this))(Stixy.board.id));
			if(this.inProgress){ 
				Stixy.board.resetBoardListItemState();
				Stixy.server.abort(); 
			}
			if(this.not_authorized()){ 
				this.storedNavigation = arguments;
				return;
			}
			this.inProgress = true;
			if(save_changes!==false){
				Stixy.server.update(function(request){
					Stixy.widgets.removeAll();
    			this.succeded(request);
					Stixy.board.updateBoardList(id);
				});
			}else{
				Stixy.server.reset();
			}
			this.setBoardListItemState(id);
			this.new_stixyboard = (!id);
			this.update(((token) ? '/invitation/join_ajax?token=' + token : '/public/index/' + id))
			if(token){ Stixy.board.updateBoardListItem(id) }
		},
		setBoardListItemState: function(id){
			Stixy.element.addClassName(Stixy.ui.base, "loading");
			this.old_item = Stixy.element.$ID("board_list_style_"+Stixy.board.id);
			this.new_item = Stixy.element.$ID("board_list_style_"+id);
			if(this.old_item) Stixy.element.removeClassName(this.old_item, "board-list-current");
			if(this.new_item){
				Stixy.element.addClassName(this.new_item, "board-list-current");
				Stixy.element.addClassName(this.new_item, "board-list-loading");
			}
		},
		resetBoardListItemState: function(id){
			Stixy.element.removeClassName(Stixy.ui.base, "loading");
			if(this.new_item){
				Stixy.element.removeClassName(this.new_item, "board-list-current");
				Stixy.element.removeClassName(this.new_item, "board-list-loading");
			}
		},
		update: function(url, new_stixyboard){
			Stixy.element.addClassName(Stixy.ui.base, "loading");
			//var fade = new Stixy.effects.FadeOut(Stixy.ui.canvas_content, 0.3, 0.3)
			Stixy.server.connect(null, url, function(request){
			  //fade.cancel();
			  var result = Stixy.JSON.decode(request.responseText);
				//var transitNode = Stixy.ui.canvas_content.cloneNode(true);
				//transitNode.id = ''
				//Stixy.ui.canvas_content.parentNode.appendChild(transitNode);
				//Stixy.element.setOpacity(Stixy.ui.canvas_content,0.3);
				Stixy.widgets.removeAll();
    		Stixy.JSON.replaceHTML(result);
				Stixy.ui.notification.reset();
  			Stixy.JSON.executeScript(result);
  			Stixy.ui.listen('scrolltoposition', function(){
  			  //new Stixy.effects.FadeIn(Stixy.ui.canvas_content, 0.2, 1)
  			  Stixy.element.removeClassName(Stixy.ui.base, "loading");
  			  if(this.new_item) Stixy.element.removeClassName(this.new_item, "board-list-loading");
  			  if(this.new_stixyboard) Stixy.board.updateBoardList();
  			  this.inProgress = false;
  			  this.announce("afterupdate");
    		}.b(this));
    		Stixy.ui.scrollToPosition(Stixy.ui.scrollPositions, false);
       	//new Stixy.effects.Transition(transitNode, Stixy.ui.canvas_content, 0.5, function(){
  			//  transitNode.parentNode.removeChild(transitNode)
				//}.b(this));
			}.b(this));
		},
		updateBoardListItem: 	function(id){ Stixy.server.replace(null, "/board/board_list_compact_item_ajax/" + (id||Stixy.board.id), "board_list_item_" + (id||Stixy.board.id)) }, 
		addBoardFilter: 			function(set){ 
			this.boardsBeforeNav();
			Stixy.server.replace(null, encodeURI("/board/board_list_compact_ajax/" + Stixy.board.id + "?set_filters=true&filters=" + (set==0 ? "": Stixy.ui.tagFilter.getContent())), Stixy.ui.board_list_bar, Stixy.ui.tagFilter.reset.b(Stixy.ui.tagFilter));
		},
		sendNotification: function(){ 
			Stixy.element.$ID("board_notification_send").style.display = "none";
			Stixy.element.$ID("board_notification_sendig").style.display = "inline";
			Stixy.server.replace(Stixy.XML.fromObject({message:Stixy.ui.notification.getContent()}), encodeURI("/board/send_notification/" + Stixy.board.id), Stixy.element.$ID("board_notification"), Stixy.ui.notification.reset.b(Stixy.ui.notification), function(){
				Stixy.element.$ID("board_notification_send").style.display = "block";
				Stixy.element.$ID("board_notification_sendig").style.display = "none";
				alert("We're sorry.\n\nThe notification could not be sent due to unspecified reason. Please try again.");
			});
		},
		updateBoardList: function(id,params){	this.boardsBeforeNav(); Stixy.server.replace(null, "/board/board_list_compact_ajax/" + (id||Stixy.board.id) + (params ? "?" + params : ""), Stixy.ui.board_list_bar, 
			function(){
				Stixy.ui.tagFilter.reset.b(Stixy.ui.tagFilter)();
				Stixy.ui.initAllBoardListItems.b(Stixy.ui)();
			}) 
		},
		updateBoardOptions: 	function(parameters){ Stixy.server.replace(null, "/board/board_option_ajax/" + Stixy.board.id + (parameters ? "?" + parameters : ""), Stixy.ui.bopt_bar, 
			function(){
				Stixy.ui.notification.reset.b(Stixy.ui.notification)();
			}) 
		},
		updateUtilityNav: 		function(){	Stixy.server.replace(null, "/utility_navigation_ajax", 'utility_navigation') },
		openInvite: 					function(){ Stixy.popup.open("/board/invite/" + Stixy.board.id + "?popup=true" ,null,null,Stixy.board.updateBoardOptions) },
		openSetting: 					function(){	Stixy.popup.open("/setting/index?popup=true",null,null) },
		openOverview: 				function(){	Stixy.popup.open("/board/board_list_detailed?popup=true",10000,10000) },
		openCalendar: 				function(){	Stixy.popup.open("/calendar?popup=true",10000,10000) },
		boardsBeforeNav: 			function(){ Stixy.element.addClassName(Stixy.element.$ID("board_list_scroll"),"board-loading") },
		openSignin: function(){	
			Stixy.popup.open("/signin?popup=true",null,null) 
		},
		openOption: function(){	
			Stixy.popup.open("/board/option/" + Stixy.board.id + "?popup=true",null,null) 
		},
		openTrashCan: function(){	
			Stixy.popup.open("/board/trash_can/" + Stixy.board.id + "?popup=true",null,null) 
		},
		openSignup: function(){	
			Stixy.popup.open("/signup?popup=true",null,null) 
		},
		newStixyboard: function(){
			if(this.not_authorized()){
				this.storedNavigation = arguments;
				return;
			};
			Stixy.board.navigate(0);
		},
		reset: function(){
			Stixy.server.reset();
			Stixy.popup.close();
		},
		cancelAndContinue: function(){
			Stixy.board.reset();
			if(Stixy.board.storedNavigation) Stixy.board.navigate.apply(Stixy.board, Stixy.board.storedNavigation);
		},
		updateAll: function(board_options_state,board_list_state,widget_tray_state,fetch_latest){
			Stixy.board.updateUtilityNav();
			Stixy.board.updateBoardList();
			Stixy.board.navigate(fetch_latest ? "" : Stixy.board.id);
			Stixy.ui.boptToggle(null,board_options_state,false);
			Stixy.ui.boardListToggle(null,board_list_state,false);
			Stixy.ui.trayToggle(null,widget_tray_state,false);
		},
		navigatePopup: function(e, url){
			Stixy.events.stop(e);
			window.location.href = url + ((/\?/.test(url)) ? "&" : "?") + "popup=true&from_popup=true";
		}
	}
});