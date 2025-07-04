Stixy.listen("ready",function(){
	Stixy.ui.registerElements();	
	function registerPopup(type,source,popup){
		var source = Stixy.element.$ID(source);
		if(!source) { return }
		Stixy.events.observe(source,type,function(event){
			Stixy.events.stop(event);
			popup();
		});
		Stixy.events.observe(source,"mouseover",function(event){Stixy.events.stop(event)});
		Stixy.events.observe(source,"mousedown",function(event){Stixy.events.stop(event)});
	}
	registerPopup("click","board_option_open",Stixy.board.openOption);
	registerPopup("click","share_open",Stixy.board.openInvite);	
	Stixy.ui.scrollToPosition(Stixy.ui.scrollPositions);
	Stixy.tools.addToToolbar(
 		[Stixy.widgets.Note,"widget-tray-note"],
 		[Stixy.widgets.Photo,"widget-tray-photo"],
 		[Stixy.widgets.Document,"widget-tray-document"],
 		[Stixy.widgets.Todo,"widget-tray-todo"]
 	)
});