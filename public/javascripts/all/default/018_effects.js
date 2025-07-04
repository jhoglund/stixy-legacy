Stixy.effects = (function(){
  // Random shake
  var Shake = function(x,d,f){
    return 2.0 * (Math.cos((f + (Math.PI/d)) * x) - Math.cos((f - (Math.PI/d)) * x ));
  }
        
  var Steps = function(start,stop,steps,filter){
    var items = [];
    var step = (stop-start) / steps;
    for(var i=0; i<steps; i++)
      items.push(start += (filter ? filter[i] : step));
    return items;
  }
  
  var Ease = {
    diff: function(n){
      var s = 0;
      for(var i=0; i<n; i++)
        s += Ease.sin(i, n);
      return s;
    },
    sin: function(f, a, b, d){ 
      var b = d-b 
      var s = function(x){
        return x - Math.sin(x*2*Math.PI) / (2*Math.PI);
      }
      if(a && f < a) return s(f/a);
      if(b && f > b) return 1 - s((f-b)/(d-b));
      return 1;
    }
  }
  
  var EaseInOut = function(start, stop, easein, easeout, duration){
    var steps = [];
    var step = (stop-start) / duration;
    var diff = duration/(duration-Ease.diff(easein)-Ease.diff(easeout));
    for(var i=1; i<=duration; i++)
      steps.push(step * Ease.sin(i, easein, easeout, duration+1) * diff);
    return steps;
  }
        
  var KeyFrame = function(index,tracks){
    this.index = index;
    this.tracks = tracks;
    this.easeIn = 0;
    this.easeOut = 0;
  }
  
  var Timeline = function(duration, fps){
    this.duration = duration || 1;
    this.fps = fps || 50; //((Stixy.ua.firefox && parseFloat(Stixy.ua.minor.join('.')) < 3.5) ? 25 : 50)
    this.totalDuration = this.duration * this.fps;
    this.keyFrames = {};
    this.keyIndexes = [];
    this.tracks = {};
    this.onFinished = function(){}
    this.onFrame = function(){}
    var timeouts = [];
    function id(i){ return 'key_' + i }
    this.setKeyFrame = function(key, tracks){
      this.ready = false;
      var keyFrame = new KeyFrame(key, tracks);
      this.keyIndexes.push(key);
      this.keyFrames[id(key)] = keyFrame;
      return keyFrame;
    }
    this.render = function(){
      if(this.ready) return true;
      var keyIndexes = this.keyIndexes.sort(), from, to;
      for(var i=0,x=1; i < keyIndexes.length-1; i++,x++){
        from = this.keyFrames[id(keyIndexes[i])];
        to = this.keyFrames[id(keyIndexes[x])];
        from.tracks.eachProperty(function(property,track){
          var filter = new EaseInOut(track, to.tracks[property], from.easeIn*this.fps, from.easeOut*this.fps, this.totalDuration)
          var sequence = new Steps(track, to.tracks[property], this.totalDuration, filter)
      	  this.tracks[property] = (this.tracks[property]||[]).concat(sequence);
        }.b(this));
      }
      this.ready = true;
    }
    this.start = function(){
      this.render();
      var keys = new Steps(0, this.duration*1000, this.totalDuration);
      for(var i=0, x=this.totalDuration-1; i<this.totalDuration; i++, x--){
        var timeout = setTimeout(function(index, finished){
          var frame = {};
          this.tracks.eachProperty(function(property, track){
            frame[property] = track[index]
          }.b(this));
          this.onFrame(frame, index)
          timeouts.shift();
          if(finished) this.onFinished();
        }.b(this, i, !x), keys[i])
        timeouts.push(timeout);
      }
    }
    this.cancel = function(){
      for(var i=0; i<timeouts.length; i++){
        clearTimeout(timeouts[i]);
      }
    }
  }
  
  var Fade = function(source, from, to, duration, done_callback){
    this.source = source;
    var timeline = new Timeline(duration);
	  timeline.setKeyFrame(0, { opacity:from });
	  timeline.setKeyFrame(duration, { opacity:to });
	  timeline.onFrame = function(frame){
	    Stixy.element.setOpacity(source, frame.opacity);
	  }
	  timeline.onFinished = function(frame){
	    if(done_callback) done_callback()
	  }
	  timeline.start();
    this.cancel = timeline.cancel;
  }

  var Appear = FadeIn = function(source, seconds, opacity, done_callback){
    this.source = source;
    var transition = new Fade(source, Stixy.element.getOpacity(source), (opacity||1), seconds, done_callback);
    this.cancel = transition.cancel;
  }

  var Disappear = FadeOut = function(source, seconds, opacity, done_callback){
    this.source = source;
    var transition = new Fade(source, Stixy.element.getOpacity(source), (opacity||0), seconds, done_callback);
    this.cancel = transition.cancel;
  }
  
  var Transition = function(from, to, seconds, done_callback){
	  var count = 0;
    var done = function(){
      if(++count > 1 && done_callback)  done_callback();
    }
    new Appear(to,seconds,Stixy.element.getOpacity(from),done);
    new Disappear(from,seconds,0,done);
  }
  
  return {
    Timeline: Timeline,
    Steps: Steps,
    EaseInOut: EaseInOut,
    Transition: Transition,
    Fade: Fade,
    FadeIn: FadeIn,
    FadeOut: FadeOut,
    Appear: Appear,
    Disappear: Disappear
  }
})()	
