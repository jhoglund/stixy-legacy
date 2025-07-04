// Catch external links, and open them in a new window/tab
Stixy.events.observe(document,"click",function(e){
	var element = Stixy.events.element(e);
	var uri = element.href;
	if(uri && element.tagName.toLowerCase()=="a" && (uri.search(new RegExp("^"+location.protocol+"\/\/"+location.host))==-1)){
		Stixy.events.stop(e);
		Stixy.openExternalWindow(uri)
	}
});

Stixy.events.observe(document, "keydown", function(event){
	Stixy.events.setKey(event.keyCode);
	if(event.altKey){
		Stixy.element.addClassName(document.body, "alt-key-down");
		var key_up = function(event){
			Stixy.element.removeClassName(document.body, "alt-key-down");
			Stixy.events.stopObserving(document, "keyup", key_up);
		}
		Stixy.events.observe(document, "keyup", key_up);
	}
});
Stixy.events.observe(document, "keyup", function(event){
	Stixy.events.setKey(event.keyCode, false);
});

// DOMContentLoaded
Stixy.listen("ready",function(){
	// Ad frame stuff
	var top_ad = Stixy.element.$ID('global_top_ad_frame');
	if(top_ad){
	  // move ad to one level below popup. Initialy, it sits above the load/error popup so the ad works before everything is loaded
    top_ad.style.zIndex = 999;
	  Stixy.board.listen("beforenavigate", function(){
  		top_ad.contentWindow.location.reload()
		});
		Stixy.popup.listen("close", function(){
  		top_ad.contentWindow.location.reload()
		});
	}

	var canvas = Stixy.element.$ID('stixyboard');
	if(canvas){
		function delayedScroll(){
			clearTimeout(Stixy.ui.__scroll_save_delay);
			Stixy.ui.__scroll_save_delay_set = true;
			Stixy.ui.__scroll_save_delay = setTimeout(function(){
				Stixy.ui.__scroll_save_delay_set = false;
				Stixy.ui.saveScroll();
			}.b(this),1000);
		}
		if(Stixy.ua.safari && Stixy.ua.major < 4){
		  Stixy.events.observe(window, "scroll", function(e){
			  if(Stixy.events.element(e)==Stixy.ui.canvas){
					delayedScroll();
				}
			});
		}else{
			Stixy.ui.listen("scrolltoposition", function(){
				Stixy.ui.__no_scroll_save = true;
			});
			Stixy.events.observe(canvas, "scroll", function(e){
				Stixy.events.stop(e);
				if(Stixy.ui.__no_scroll_save!=true){
					delayedScroll();
				}else{
					Stixy.ui.__no_scroll_save = false;
				}
			},true);	
		}
		Stixy.board.listen("unload", function(){
			if(Stixy.ui && Stixy.ui.__scroll_save_delay_set){
				clearTimeout(Stixy.ui.__scroll_save_delay);
				Stixy.ui.saveScroll();
				Stixy.ui.__scroll_save_delay_set = false;
			}
		});
	}

	Stixy.widgets.Optionbar.frame.announce("ready");
	var scroll_source = Stixy.element.$ID("stixyboard_hand_scroll");
	var scroll_target = Stixy.element.$ID("stixyboard");
	if(scroll_source && scroll_target){
		var canvas_scroll = Stixy.features.Scroll(null, {source:scroll_source,target:scroll_target});
	}
});

// Widgets loaded
Stixy.listen("ready", function(){
	setTimeout(function(){
		var widget_id = document.location.pathname.match(/^\/board\/\d+\/widget\/(\d+)/)
		if(widget_id){
			try{
				Stixy.widgets.getWidget(widget_id[1]).scrollIntoView(true, /\/edit/.test(document.location.pathname)); 
			}catch(e){ }
		}
	},100)
});

// DOMContentLoaded
Stixy.listen("ready",function(){
	var load_error_frame = Stixy.element.$ID("load_error_frame");
	if(load_error_frame){
		try{
  		load_error_frame.parentNode.removeChild(load_error_frame);
    }catch(e){ new StixyError(e, "033_event_observers.js line 94") }
	}
});


/* Support for the DOMContentLoaded event is based on work by Dan Webb,
   Matthias Miller, Dean Edwards and John Resig. */
(function() {
  var loaded = false;
  (function(loaded) {
    var timer;
    function fireContentLoadedEvent(){
      if(loaded) return
      if(timer) window.clearInterval(timer);
      //if(window.parent) window.parent.console.log(9999)
      Stixy.state.ready = true;
      loaded = true;
      Stixy.announce("ready");
    }
    if(document.addEventListener){
     if(Stixy.ua.webkit) {
       timer = window.setInterval(function(){
         if(/loaded|complete/.test(document.readyState)){
           fireContentLoadedEvent();
         }
       }, 0);
       Stixy.events.observe(window, "load", fireContentLoadedEvent);
     }else if(Stixy.ua.firefox && Stixy.ua.major < 3 && window.frameElement){
       // Firefox 2 doesn't fire DOMContentLoaded for frames
       Stixy.events.observe(window, "load", fireContentLoadedEvent);
     }else{
       document.addEventListener("DOMContentLoaded", fireContentLoadedEvent, false);
     }
    }else{
      document.write("<script id=__onDOMContentLoaded defer src=//:><\/script>");
      document.getElementById('__onDOMContentLoaded').onreadystatechange = function(){
        if(this.readyState == "complete") {
          this.onreadystatechange = null;
          fireContentLoadedEvent();
        }
      }
    }
  })(loaded);
})();

