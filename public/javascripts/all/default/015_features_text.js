// # TODO
// Known bugs:
// Safari: If one creates a link and have only selected one character, the character is not replaced
// by the link label, but pushed to the right.

Stixy.features.Text = (function(){
  var Text = function(widget, attributes){
    Stixy.features.Base.call(this, widget, attributes)
  	this.updated = false;
    this.document = document;
  	this.nativeEditor = nativeEditor();
  	this.pendingOpen = false;
  	this.editableState = true;
  	if(this.nativeEditor){
  		this.editor = null;
  		this.editable = function(state){
  			this.editableState = state===false ? false : true;
  			this.source.contentEditable = this.editableState;
  		}
  	  try {
  			document.execCommand('enableInlineTableEditing', false, "false");
      	document.execCommand('enableObjectResizing', false, "false");
  		}catch(e) { }
  		this.update = function(){
  		if(this.updated==false){
  			this.announce("beforeedit");
        this.updated = true;
      }
  	  }.b(this);
  		if(document.attachEvent){
  			this.observe(this.source, "mousedown", function(){
  				if(widget.focus){ widget.focus.giveFocus() };
  				if(widget.order){ widget.order.changeOrder() };
  			}.b(this));
  			this.observe(this.source, "beforeeditfocus", function(){
  			  if(!this.hasFocus){
    			  this.hasFocus = true;
    				this.observe(document, "keyup", this.update);
    				this.selection = document.selection;
    				var eventMouseDown = function(){
    					this.announce("beforeedit");
    					this.announce("gotfocus");
    					this.stopObserving(document, "mouseup", eventMouseDown.b(this));
    				}
    				this.observe(document, "mouseup", eventMouseDown.b(this));
    			}
  			}.b(this));
  			this.observe(document, "selectionchange", function(){
  				this.announce("textselected");
  	    }.b(this));
  		  this.observe(this.source, "beforedeactivate", function(){
  			  this.stopObserving(document, "keyup", this.update);
  				if( !Stixy.element.contained(event.toElement,this.widget.optionbar.base) && 
  				    !Stixy.element.contained(event.toElement,Stixy.ui.wopt_show) &&
  				    !Stixy.element.contained(event.toElement,Stixy.ui.wopt_hide)
  				  ){	
  					this.announce("lostfocus");
  				}
  				this.hasFocus = false;
  			}.b(this));
  		}else{
        // ====================================================================================
        // = # TODO: From old js file. This needs to be refactored in a better way            =
        // = The activeElement is set in the loadOptionbar method in 032-widgets_optionbar.js =
        // ====================================================================================
  			this.observe(this.source, "focus", function(e){
  			  var eventLostFocus = function(e){
  			    setTimeout(function(){ // allow the focus event to set the activeElement before the blur event
      				if(Stixy.element.contained(document.activeElement, this.widget.optionbar.panel)){ return }
  				    this.stopObserving(this.source, "blur", eventLostFocus);
    				  this.announce("lostfocus");
  				  }.b(this),100)
    			}
  				this.observe(this.source, "blur", eventLostFocus.b(this));
  				var eventOutsideClick = function(e){
  			    if(!Stixy.events.contained(e,this.source) && !Stixy.events.contained(e,this.widget.optionbar.panel)){
  				    this.stopObserving(document, "click", eventOutsideClick);
      				this.source.blur();
  				  }
  				}
    			this.observe(document, "click", eventOutsideClick.b(this));
  				var eventMouseDown = function(){
  					this.announce("beforeedit");    			
  					this.announce("gotfocus");
  					this.stopObserving(document, "mouseup", eventMouseDown.b(this));
  				}
  				this.observe(document, "mouseup", eventMouseDown.b(this));
  				this.observe(document, "keyup", this.update);
  				this.selection = window.getSelection();
  			}.b(this));
  		  
        // var sourceGotFocus = function(e){
        //   this.hasFocus = true;
        //          var eventOutsideClick = function(e){
        //            if( !Stixy.element.contained(Stixy.events.element(e), this.widget.optionbar.base) &&  
        //                !Stixy.element.contained(Stixy.events.element(e), this.source) && 
        //                !Stixy.element.contained(Stixy.events.element(e), Stixy.ui.wopt_show) &&
        //                !Stixy.element.contained(Stixy.events.element(e), Stixy.ui.wopt_hide)
        //              ){
        //              this.stopObserving(this.widget.element, "mousedown", eventOutsideClick);
        //              this.stopObserving(document, "mousedown", eventOutsideClick);
        //              this.source.blur();
        //            }else{
        //              Stixy.events.halt(e);
        //            }
        //          }
        //          this.observe(document, 'keydown', function(e){
        //            if(e.keyCode == 9 && this.hasFocus){
        //              eventOutsideClick();
        //            }
        //          }.b(this))
        //          this.observe(this.widget.element, "mousedown", eventOutsideClick.b(this));
        //          this.observe(document, "mousedown", eventOutsideClick.b(this));
        //  var eventMouseDown = function(){
        //    this.announce("beforeedit");          
        //    this.announce("gotfocus");
        //    this.stopObserving(document, "mouseup", eventMouseDown.b(this));
        //  }
        //  this.observe(document, "mouseup", eventMouseDown.b(this));
        //  this.observe(document, "keyup", this.update);
        //  this.selection = window.getSelection();
        //        }
        // this.observe(this.source, "focus", sourceGotFocus.b(this));
        //        this.observe(this.source, "blur", function(e){
        //  this.hasFocus = false;
        //   this.stopObserving(document, "mouseup", sourceGotFocus);
        //        }.b(this));
        // window.listen("textselected", function(source){
        //   if(Stixy.element.contained(source,this.source)){
        //            this.reformatMozBogusNode();
        //            this.announce("textselected");
        //   }
        // }.b(this));
        //        this.observe(this.source, "blur", function(event){
        //          this.stopObserving(document, "keyup", this.update);
        //  this.announce("lostfocus");
        // }.b(this));
  		}
    }else{
  		this.editable = function(state){
  			this.editableState = state===false ? false : true;
  			if(!this.editableState){
  				this.destroy();
  			}
  		}
  		this.editor.text = this;
  	  this.editor.widget = widget
  		this.eventCreate = function(){this.announce("gotfocus") }.b(this);
  		this.eventBeforemove = function(){ this.destroy() }.b(this);
  		this.eventBeforeresize = function(){ this.destroy() }.b(this);
  		this.eventBeforeedit = function(){this.announce("beforeedit") }.b(this);
  		this.eventLostfocus = function(){ this.destroy() }.b(this);
  		this.eventTextselected = function(){
  			this.selection = this.editor.selection;
  			this.announce("textselected");
      }.b(this);
  	}
    this.getSource = function(){
  		if(this.editor && (this.editor.widget==this.widget && this.editor.window)){
        this.editor.updated = false;
        var text = this.editor.body.innerHTML;
      }else{
  			this.updated = false;
        var text = this.source.innerHTML;
      }
  		return text.replace(/&(lt|gt);/g,"&__STIXYREMOVE__$1;")
    }
  	this.giveFocus = function(){
  		if(this.editor){
  			this.editor.window.contentWindow.focus();
  		}
  	}
  	this.waitToOpen = function(){
  		this.openEditor();
  	}
    this.openEditor = function(){
  		if(this.editor.initiating==true || !this.editableState) return
  		this.widget.move.listen("beforemove", this.eventBeforemove);
  		this.widget.resize.listen("beforeresize", this.eventBeforeresize);
  		this.widget.focus.listen("lostfocus", this.eventLostfocus);
  		this.editor.listen("create", this.eventCreate);
  		this.editor.listen("beforeedit", this.eventBeforeedit);
  		this.editor.listen("textselected", this.eventTextselected);
  		this.editor.open(this.source, this.widget);
    }
    this.destroy = function(){
  		if(this.editor && this.editor.initiating==true) return
  		this.widget.move.unlisten("beforemove", this.eventBeforemove);
  		this.widget.resize.unlisten("beforeresize", this.eventBeforeresize);
  		this.widget.focus.unlisten("lostfocus", this.eventLostfocus);
  		if(this.editor){
  			this.editor.unlisten("create", this.eventCreate);
  			this.editor.unlisten("beforeedit", this.eventBeforeedit);
  			this.editor.unlisten("textselected", this.eventTextselected);
  			this.editor.destroy();
  		}
  		this.announce("lostfocus");
    }
    this.catchMousedown = function(event){
      Stixy.events.halt(event);
  		if(this.editor){
  			this.editor.beforeEdit = this.beforeEdit;
  			this.observe(this.source, "mouseup",  this.openEditor.b(this));
      }
  	}
  	// To catch and cancel drag/resize and any other possible mousedown events
    this.observe(this.source, "mousedown", this.catchMousedown.be(this), true);
    // Link tooltip for the instance
    this.linkTooltip = new Text.LinkTooltip(this.widget.element);
    this.observe(this.source, "mouseover", function(e){
      this.linkTooltip.showUnless(e, this.widget);
    }.b(this));
    this.linkTooltip.listen("editclick", function(e,link,href,label){
      this.editLink(link,href,label)
    }.b(this));
    this.linkTooltip.listen("linkclick", function(e,link,href){
      Stixy.openExternalWindow(href);
    }.b(this));

  }
  
  // Text selection for Safari and Firefox. Comparable to IE "onselectionchange" native event.
	
  if(!document.attachEvent){
    this.handleTextSelect = function(e){
		  if(window.getSelection().rangeCount > 0){
    		var _tmp_select = window.getSelection().getRangeAt(0);
    		try{
    			if(!this._tmp_select_compare || this._tmp_select_compare.collapsed || (_tmp_select.compareBoundaryPoints(Range.START_TO_START,this._tmp_select_compare)!=0)||(_tmp_select.compareBoundaryPoints(Range.END_TO_END,this._tmp_select_compare)!=0)){
    				window.announce("textselected", Stixy.events.element(e));
    			}
    		}catch(e){ }
		    this._tmp_select_compare = _tmp_select
    	}
    }.b(this);
  	Stixy.events.observe(document, "mouseup",  this.handleTextSelect);
		Stixy.events.observe(document, "keyup",  this.handleTextSelect);
	}
  
  
// ===========
// = Methods =
// ===========  
  
  /*----------------------------------------
  
  Firefox 3 has a bug that disables execCommand to work as supposed. This happens when all content of a node with 
	contenteditable="true" is selected and the node is a child of another node (other than body). This is a patch that 
	adds an extra node outside of the selection. This enables the execCommand 
	to work, since all content of the node is no longer selected.
	
	Also, text can't be formated if the text node is the first node inside, text in that node can't be formated with execCommand
	http://fretlessjazz-ux.blogspot.com/2009/09/implementing-rich-text-editor-with.html
  ----------------------------------------*/
  var mozEditorBlockSpacerName = 'sx:moz-editor-block-spacer';
  
  var addMozBogusNode = function(source){
    if(Stixy.ua.gecko){
      if(!hasMozBogusNode(source)){
        var bogusNode = document.createElement(mozEditorBlockSpacerName);
        bogusNode.appendChild(document.createElement('div'));
        source.insertBefore(bogusNode, source.firstChild)
      }
      return bogusNode;
    }
  }
  
  var getAllMozBogusNodes = function(source){
    return source.getElementsByTagName(mozEditorBlockSpacerName);
  }
  
  var getMozBogusNode = function(source){
    return getAllMozBogusNodes(source).item(0);
  }
 
  var hasMozBogusNode = function(source){
    return getMozBogusNode(source) != null
  }
  
  var replaceMozBogusNode = function(source){
    var nodes = getAllMozBogusNodes(source);
    for(var i=0; i<nodes.length; i++)
      source.removeChild(nodes[i]);
    return addMozBogusNode(source);
  }

  var reformatMozBogusNode = function(){
    if(Stixy.ua.gecko){
      var selection = this.getSelection();
      if(selection.anchorNode == this.source && selection.anchorOffset == 0){
        var bogusNode = replaceMozBogusNode(this.source);
        var range = document.createRange();
        range.setStart(bogusNode.nextSibling,0);
        range.setEnd(selection.focusNode, selection.focusOffset);
        selection.removeAllRanges();
        selection.addRange(range);
      }
    }
  }
  
  // =================
  // = Range methods =
  // =================
  
  var getRange = function(){
    var selection = this.getSelection();
    return  selection.createRange ? selection.createRange() :
            selection.rangeCount  ? selection.getRangeAt(0) : document.createRange();
  }
  
  var selectionToRange = function(selection){
    var selection = selection || this.getSelection();
    var range = this.getRange();
    if(!selection.createRange){
      range.setStart(selection.anchorNode, selection.anchorOffset);
      range.setEnd(selection.focusNode, selection.focusOffset);
    }
    return range;
  }

  var rangeToSelection = function(range){
    if(range.select){
      range.select();
    }else{
      this.collapseSelection();
      this.getSelection().removeAllRanges();
      this.getSelection().addRange(range);
    }
  }
  
  // =====================
  // = Selection methods =
  // =====================
  
  
  // Moves the selection focus to the begining of a specified node
  // # TODO: Make IE compatible
  var moveSelectionTo = function(node){
    var selection = this.getSelection();
    if(document.createRange){
      var range = document.createRange();
      range.setStart(node,0);
      range.setEnd(node,0);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  }
  
  
  var trimSelection = function(){
    var selection = this.getSelection();
    var range = this.getRange();
    if(range.text){
      // We only need to do this for IE, for now, since the W3 compatible selectWord method does the same
      var text = range.text;
      var offsetLeft = text.search(/\S(?!^\s)/);
      var offsetRight = text.search(/\s+$/);
      offsetRight -= (offsetRight >= 0) ? text.length : offsetRight;
      range.moveStart('character', offsetLeft);
      range.moveEnd('character', offsetRight);
      range.select();
    }
  }

  var getSelection = function(){
    return this.nativeEditor ? (document.selection || window.getSelection()) : this.editor.window ? this.editor.window.contentWindow.getSelection() : window.getSelection();
  }
  
  var getSelectionNodes = function(){
  	var anchorNode, anchorOffset, selection = this.getSelection();
    if(document.selection){
  		var range = selection.createRange();
      range.pasteHTML('<i id="_ie_bocus_cursor_position" style="position:absolute;width:0;overflow:hidden;">_ie_bocus_cursor_position</i>');
  	  var bogusNode = range.parentElement();
  		anchorNode = range.parentElement().parentElement;
  		anchorOffset = anchorNode.innerText.search(/_ie_bocus_cursor_position/);
  		anchorNode.removeChild(bogusNode);
  	}else{
  	  anchorNode = selection.anchorNode;
  		anchorOffset = selection.anchorOffset;
  	  focusNode = selection.focusNode;
  		focusOffset = selection.focusOffset;
  	}
  	return { anchorNode:anchorNode, anchorOffset:anchorOffset, focusNode:focusNode, focusOffset:focusOffset }
  }
  
  var collapseSelection = function(){
    var selection = this.getSelection();
    if(document.selection){
      // IE
      selection.empty();
    }else{
      try{
        selection.collapse(null,0);
      }catch(e){ 
        try{
          //selection.collapseToStart();
        }catch(e){ }
      }
    }

  }

  
  // ================
  // = Node methods =
  // ================
  
  // Find first matching node below or above in the document hieracy relative to the startNode
  // If no startNode, start with the top most node in the document
  var findNode = function(startNode, test, above){
    var startNode = startNode || document;
    var test = test || function(node){ return startNode != node };
    var sibling = above ? 'previousSibling' : 'nextSibling';
    var child = above ? 'lastChild' : 'firstChild';
    var traverse = function(node, up){ 
      // Never go down in child nodes if traversing up to parent, or the find direction is "above" and it is first run of travering
      var childNode = up ? null : node[child];
      var nextNode = childNode || node[sibling] || node.parentNode;
      var beforeEntrying = (nextNode==childNode);
      var beforeLeaving = (nextNode==node.parentNode);
      return (test(node, nextNode, beforeEntrying, beforeLeaving) || !node) ? node : traverse(nextNode, beforeLeaving); 
    }
    return traverse(startNode, above)
  }

  // Find first matching node below document hieracy relative to the startNode
  var findNodeBelow = function(startNode, test){
    return this.findNode(startNode, test, false);
  }

  // Find first matching node above document hieracy relative to the startNode
  var findNodeAbove = function(startNode, test){
    return this.findNode(startNode, test, true);
  }

  var findParentNode = function(node, test){
    var test = test || function(){ return true };
    while(node = node.parentNode)
      if(test(node, node.parentNode))
        return node;
    return null;
  }

  var findNodeInside = function(startNode, stopNode, test, above){
    var test = test || function(){ return true };
    var node = (startNode == stopNode) ? null : this.findParentNode(startNode, function(node, nextNode){
      return (node == stopNode) || test(node, nextNode);
    });
    return (node == stopNode) ? null : node;
  }

  var findSiblingNode = function(node, test, above){
    var test = test || function(){ return true };
    var sibling = above ? 'previousSibling' : 'nextSibling';
    while(node = node[sibling])
      if(test(node, node[sibling]))
        return node;
    return null;
  }
  
  var findSiblingNodeAt = function(node, index, test){
    var i=0;
    var test = test || function(){ return true };
    while(node = node.nextSibling){
      if(isTextNode(node)) continue;
      if(test(node, node.nextSibling, i++) && i==index)
        return node;
    }
    return null;
  }

  var findChildNode = function(startNode, test){
    var test = test || function(){ return true };
    var stopNode = startNode.parentNode
    var node = !startNode.firstChild ? null : this.findNode(startNode.firstChild, function(node, nextNode){
      return test(node, nextNode) || node.parentNode == stopNode;
    });
    return !node || node.parentNode==stopNode ? null : node;
  }

  var findTextNode = function(node, regExpOrFn, above){
    var test = regExpOrFn instanceof RegExp ? function(node){ return regExpOrFn.test(node.data) } : regExpOrFn || function(){ return true }
    return this.findNode(node, function(node, nextNode){
      return node.nodeName == "#text" && test(node, nextNode);
    }, above);
  }
  
  var nextNode = function(node, left){
    var sibling = node[left ? 'previousSibling' : 'nextSibling'];
    return (node.hasChildNodes && node.hasChildNodes()) ?
       this.nextNode(node[left ? 'firstChild' : 'lastChild'], left) :
       sibling ? this.nextNode(sibling, left) : node;  
  }
    
  var isTextNode = function(node){
    if(!node || !node.nodeName) return false;
    return node.nodeName == "#text";
  }
  
  var isElementNode = function(node){
    if(!node || !node.nodeName) return false;
    return isTextNode(node)===false;
  }
  
  var createElement = function(tagName, attributes){
    var element = document.createElement(tagName);
    (attributes || {}).eachProperty(function(attribute, value){
      element.setAttribute(attribute, value);
    });
    return element;
  }
  
  var insertAroundNode = function(newChild, refChild){
    refChild.parentNode.insertBefore(newChild, refChild);
    newChild.appendChild(refChild);
    return newChild;
  }
  
  
  // ================
  // = Text methods =
  // ================
  
  var getText = function(element){
    return element.textContent || element.innerText || '';
  }

  var selectElementText = function(element){
    var selection = this.getSelection();
    var range = document.createRange ? document.createRange() : selection.createRange();
    if(range.moveToElementText){
      range.expand('textedit');
      range.moveToElementText(element);
      range.select();
    }else{
      this.collapseSelection();
      range.selectNode(element);
      selection.addRange(range);
    }
    this.focus();
    return range;
  }

  var replaceText = function(text){
    var selection = this.getSelection();
    if(selection.createRange){
      var range = selection.createRange();
      range.pasteHTML(text);
      range.moveStart('character', -text.length);
      range.select();
    }else{
      var storeEditorValues = this.getEditorValues();
      var range = document.createRange();
      range.setStart(selection.anchorNode, selection.anchorOffset);
      range.setEnd(selection.focusNode, selection.focusOffset);
      range.deleteContents();
      var fragment = range.createContextualFragment('');
      var node = document.createTextNode(text);
      fragment.appendChild(node);
      range.insertNode(fragment);
      range.setStart(node, 0);
      range.setEnd(node, text.length);
      selection.removeAllRanges();
      selection.addRange(range);
      this.setEditorValues(storeEditorValues);
    }
    this.focus();
    return node;
  }
  
  var selectTextNode = function(node){
    var selection = this.getSelection();
    if(selection.createRange){
      var range = selection.createRange();
      range.text = text;
      range.moveStart('character', -text.length)
      range.select();
    }else{
      var range = document.createRange();
      range.selectNode(node);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    this.focus();
    return range;
  }

  var selectWord = function(){
    if(document.selection){
      // # TODO: Fix word selection for IE. For now, trim white spaces of any selection.
      this.trimSelection();
      return;
    }
    var selection = this.getSelection();
    try{
    	var editor = this.source;
      var selectionNodes = this.getSelectionNodes();
      var blockElement = function(node){
        if(!node) return false;
        displayProperty = (node.style) ? node.currentStyle ? node.currentStyle.display : document.defaultView.getComputedStyle(node,false).getPropertyValue('display') : null;
      	return (displayProperty && !(/inline/.test(displayProperty))) || (node.tagName == 'BR' );
      }
      var getTextNode = function(above){
        function test(node, nextNode, beforeEntrying, beforeLeaving){
          return  blockElement(nextNode) || 
                  (isTextNode(node) && (/\s(?:\S)|(?:\S)\s/.test(node.data)) ||
                  (isTextNode(nextNode) && (above ? /\s$/ : /^\s/).test(nextNode.data)))
        }
        return this.findNode(selectionNodes.anchorNode, test, above);
      }
      var sameAnchorNode, anchorData, anchorOffset = 0;
      var sameFocusNode, focusData, focusPadding, focusOffset = 0;
      var anchorNode = getTextNode.b(this)(true);
      var focusNode = getTextNode.b(this)(false);

      if(!isTextNode(anchorNode)){
        anchorNode = this.findTextNode(anchorNode);
      }
      sameAnchorNode = anchorNode == selectionNodes.anchorNode;
      anchorData =  !sameAnchorNode ? anchorNode.data : anchorNode.data.substr(0,selectionNodes.anchorOffset);
      anchorOffset = anchorData.search(/\s(?!.*\s)/) + 1;

      if(!isTextNode(focusNode)){
        this.findChildNode(focusNode, function(node){
          focusNode = isTextNode(node) ? node : focusNode;
          return false;
        });
      }
      if(isTextNode(focusNode)){
        sameFocusNode = focusNode == selectionNodes.focusNode;
        focusData = !sameFocusNode ? focusNode.data : focusNode.data.substr(selectionNodes.focusOffset);
        focusPadding = sameFocusNode ? selectionNodes.focusOffset : 0;
        focusOffset = focusData.search(/\s/);
        focusOffset = (focusOffset < 0 ? focusData.length : focusOffset) + focusPadding;
      }

      // Extend to select word
      if(selection.getRangeAt){
        selection.removeAllRanges()
        var range = document.createRange();
        range.setStart(anchorNode, anchorOffset);
        range.setEnd(focusNode, focusOffset);
        selection.removeAllRanges();
        selection.addRange(range);
      }else{
      }
    }catch(e){ new StixyError(e, "015_feature_text.js line 607") }
  }
  
  // =====================
  // = Formating methods =
  // =====================
  
  var getEditorValues = function(){
    var range = this.selectionToRange();
    var selection = this.getSelection();
    // Select first character to query command against
    if(selection.anchorNode){
      var range = range.cloneRange();
      selection.anchorNode.parentNode.normalize()
      var selectionNode = this.findTextNode(selection.anchorNode);
      if(selectionNode && selection.extend){
        selection.collapse(selectionNode, 0);
        selection.extend(selectionNode, 1);
      }
    }else{
      var selectionRange = selection.createRange();
      var dupRange = range.duplicate();
      dupRange.collapse();
      dupRange.moveEnd('character', 1);
      dupRange.select();
    }
    
    var commandStates = ["justifycenter", "justifyfull", "justifyleft", "justifyright", "strikethrough", "bold", "italic", "subscript", "superscript", "underline"];
    var commandValues = ["fontsize", "forecolor", "hilitecolor", "fontname"];

    var storeEditorValues = {};
    function store(command,value){
      storeEditorValues[command] = value;
    }
    for(var i=0; i<commandStates.length; i++){
      var command = commandStates[i];
      try{
        store(command, document.queryCommandState(command))
      }catch(e){ continue }
    }
    for(var i=0; i<commandValues.length; i++){
      var command = commandValues[i];
      try{
        store(command, document.queryCommandValue(command));
      }catch(e){ continue }
    }
    if(!storeEditorValues.fontsize.length || /[^\d]+/.test(storeEditorValues.fontsize) && !Stixy.ua.ie){
      // Firefox does not always return font size for queryCommandValue, and Safari returns it in px size
      function stop(node){
        return (node.nodeType == 1 && node != this.source)
      }
      var node = this.findParentNode(selectionNode, stop);
      if(node == this.source){
        node = this.findParentNode(selection.focusNode, stop);
      }
      if(node){
        var fontSize = 2;
        var val = parseInt(document.defaultView.getComputedStyle(node, null).getPropertyValue("font-size"));
        var sizes = [10,13,16,18,24,32,48]
        for(var i=0; i<sizes.length; i++){
          if(val <= sizes[i]){
            fontSize=++i; 
            break;
          }
        }
        store('fontsize', fontSize)
      }
    }
    if(Stixy.ua.gecko || Stixy.ua.safari){ 
      //function find(node, tagName){
      //  return this.findNodeInside(node, this.source, function(node){
      //    return node.tagName == tagName;
      //  })
      //}
      //if(find.b(this)(selection.anchorNode, 'UL') || find.b(this)(selection.focusNode, 'UL')){
      //  store('insertunorderedlist', true)
      //}else if(find.b(this)(selection.anchorNode, 'OL') || find.b(this)(selection.focusNode, 'OL')){
      // store('insertorderedlist', true)
      //}
    }
    this.rangeToSelection(range);
    return storeEditorValues;
  }

  var setEditorValues = function(storeEditorValues){
    document.execCommand('removeformat', false, false);
    storeEditorValues.eachProperty(function(command,value){
      if(value !== false && value.length !== 0){
        try{
          document.execCommand(command, false, value);
        }catch(e){ }
      }
    })
    return true;
  }

  // Remove all tags except links
  var resetFormating = function(storeEditorValues){
    var links = this.source.getElementsByTagName('A');  
    var anchors = [];
    for(var i=0; i<links.length; i++){
      var link = links[i];
      var href = link.getAttribute('href');
      var text = this.getText(link);
      if(href && text.length > 0){
        link.innerHTML = "_STIXY_START_ANCHOR_" + i + "_" + text + "_STIXY_END_ANCHOR_";
        anchors.push({ index:i, href:href });
      }
    }
    var text = this.getText(this.source);
    text = text.replace(/_STIXY_END_ANCHOR_/gm, "</a>")
    while(anchors.length > 0){
      var anchor = anchors.shift();
      text = text.replace(new RegExp("_STIXY_START_ANCHOR_" + anchor.index + "_" , 'gm'), '<a href="' + anchor.href + '">')
    }
    this.source.innerHTML = text;
    addMozBogusNode(this.source);
  }
  
  // ================
  // = Misc methods =
  // ================
  
  var nativeEditor = function(){
    return document.body.contentEditable !== undefined;
  }
  
  var getDocument = function(){
    if(this.editor){
  		if(this.editor.window) { return this.editor.window.contentDocument }
  		return document;
    }else{
  		return document;
    }
  }

  var focus = function(){
    if(nativeEditor()){
  		var storedSelection = this.selectionToRange();
  		this.source.focus();
      this.rangeToSelection(storedSelection);
    	this.announce("beforeedit");
  		this.announce("gotfocus");
    }else{
      this.editor.setEditorFocus();
    }
  }

  var editLink = function(link, href, label){
    if(Stixy.ua.unless(/Firefox\/2/)){
      if(link && href){
        this.selectElementText(link);
        this.openEditLinkPopup(link, href, label)
      }    
    }
  }

  var validURL = function(link_value){
    if(!link_value || !link_value.match(/^(http\:\/\/|mailto\:\/\/|https\:\/\/|ftp\:\/\/|[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}|.*?@.+\.\w{2}/)){
      var error_value = link_value.match(/\w+/) ? '"'+link_value+'" is not recogized as a web address or an e-mail address. '  : '';
      alert(error_value + 'Please add a valid address in the "Link field" before pressing the "Insert link" button.')
      return false;
    }
    return true;
  }

  var openEditLinkPopup = function(link, value, label, callback){
    
    var selection = this.getSelection();
    //if(selection.isCollapsed){
    //  this.selectWord();
    //}
    this.trimSelection();
    // Use selected text if pattern match url format
    var selectedText = document.selection ? this.getSelection().createRange().text : this.getSelection().toString();
    if(!value && selectedText.search(/^(http\:\/\/|mailto\:\/\/|https\:\/\/|ftp\:\/\/|[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}|.*?@.+\.\w{2}/) != -1){
      // if a text that is probably a link is selected
      var predefinedValue = selectedText;
    }
    
    var edit = {
      replace: <%= { 
        :popup_content => render( :partial => "/widgets/note/link_popup", :locals => { :edit => false }),
        :popup_buttons => render( :partial => "/widgets/note/link_popup_buttons", :locals => { :edit => false }),
      }.to_json %>
    }
    var insert = {
      replace: <%= { 
        :popup_content => render( :partial => "/widgets/note/link_popup", :locals => { :edit => true }),
        :popup_buttons => render( :partial => "/widgets/note/link_popup_buttons", :locals => { :edit => true }),
      }.to_json %>
    }
    var json = !value ? edit : insert;

    // Populate fields in the popup
    if(predefinedValue || value){
      json.replace.popup_content = json.replace.popup_content.replace(/(id="link"[^<>]* value=")(.*?)(")/, '$1'+(value || predefinedValue)+'$3');
    }
    label =  label || (selection.createRange ? selection.createRange().text : selection.toString());
    if(label){
      json.replace.popup_content = json.replace.popup_content.replace(/(id="label"[^<>]* value=")(.*?)(")/, '$1'+label+'$3')
    }

    // Selection is lost when focus is moved to the input fields in the popup, 
    // so we need to store it and reset it once returned from the popup
    var storedSelection = this.selectionToRange();

    var cancelPopup = function(){
      this.focus() 
      this.rangeToSelection(storedSelection);
      Stixy.popup.unlisten('cancel', cancelPopup);
    }
    var showPopup = function(popupWindow){
      popupWindow.insertLink = function(e){
        Stixy.popup.unlisten('actionkey', popupWindow.insertLink);
        var link = popupWindow.Stixy.element.$ID("link");
        var label = popupWindow.Stixy.element.$ID("label");
        Stixy.popup.result = { link:link.value, label:label.value };
        Stixy.popup.done();
      };
      popupWindow.removeLink = function(){
        Stixy.popup.result = { remove:true };
        Stixy.popup.done();
      };
      popupWindow.navigate = function(url){
        var link = popupWindow.Stixy.element.$ID("link");
        var link_value = link.value;
        if(!link_value.match(/^.*?:\/\//)){
      		link_value = "http://"+link_value;
      	}
      	if(validURL(link_value)){
          popupWindow.Stixy.openExternalWindow(link_value);
      	}
      };
      popupWindow.cancel = function(){
        Stixy.popup.cancel();
      };
      setTimeout(function(){
        var link = popupWindow.Stixy.element.$ID("link");
        if(link){
          link.focus();
        }
      },100);
      if(!Stixy.ua.ie){
      // This needs to be fixed to work in IE. It seems like IE loses the focus when the return key is hit. We need to cancel the event first
        Stixy.popup.listen('actionkey', popupWindow.insertLink);
      }
    }

    Stixy.popup.listen('cancel', cancelPopup.b(this));
    Stixy.popup.listen('show', showPopup.b(this));

    Stixy.popup.populate(json, 370,225, function(){
      Stixy.popup.unlisten('cancel', cancelPopup);
      Stixy.popup.unlisten('show', showPopup);
      var remove_link = Stixy.popup.result.remove;
      var link_value = Stixy.popup.result.link || '';
      var link_label = Stixy.popup.result.label;
      (callback || new Function)();
      // Reset selection
      this.rangeToSelection(storedSelection);
      var selection = this.getSelection();
      if(remove_link){
        this.focus();
        document.execCommand("unlink", false, false);
      }else{
        // Validation
        if(!this.validURL(link_value)){
    		  this.focus();
          return;
    		}

        if(link_value.match(/.*?@.+\.\w{2}/)){
          if(!link_value.match(/^.*?:\/\//)){
            link_value = "mailto://"+link_value;
          }
        }else if(!link_value.match(/^.*?:\/\//)){
    			link_value = "http://"+link_value;
    		}
        link_label = link_label || link_value;
        var node = this.replaceText(link_label);
        if(Stixy.ua.gecko){
          var link = insertAroundNode(createElement('a', { href:link_value }), node)
          this.selectElementText(link);
        }else{
          document.execCommand('createlink', false, link_value);
        }
      }
      this.update();
    }.b(this))
  }

  // Link tooltip
  Text.LinkTooltip = function(source){
    this.source = source;
    this.visible = false;
    this.element = (function(){
      var container = document.createElement("div");
      var edit = document.createElement("div");
      container.innerHTML = '<sx:button class="tooltip button-icon"><sx:i></sx:i><sx:l><sx:p> </sx:p></sx:l><sx:r><sx:p></sx:p></sx:r><sx:t><span class="button-label">Edit link</span></sx:t></sx:button>'
      container.className = 'edior-link-tooltip';
      edit.className = 'edior-link-label';
      container.appendChild(edit);
      source.appendChild(container);
      this.edit = edit;
      // Click event breaks in IE. Something else is catching it.
      Stixy.events.observe(edit, "mousedown", this.editLink.b(this));
      Stixy.events.observe(container, "mousedown", this.navigateLink.b(this));
      return container;
    }.b(this))();
  }
  Stixy.extend(Text.LinkTooltip.prototype, {
    showUnless: function(e, widget){
      if(widget.locked) return;
      var element = Stixy.events.element(e);
      var link = (function(){
        function isAnAnchor(node){
          return (node.getAttribute && node.nodeName == "A" && node.getAttribute('href'));
        }
        return  isAnAnchor(element) ? element : widget.text.findNodeInside(element, widget.text.source, isAnAnchor);
      })()
      if(link){
        this.link = link;
        this.href = link.getAttribute('href');
        this.label = link.textContent || link.innerText;
        this.show(e, link, widget);
      }
    },
    show: function(e, element, widget){
      if(this.getState(element)) return;
      var hideEvent = function(e){
        var element = Stixy.events.element(e);
        if(!Stixy.element.contained(element, this.element) && element!=this.link && !Stixy.element.contained(element, this.link) ){
          Stixy.events.stopObserving(document, "mousemove", hideEvent);
          this.hide();
        }
      }.b(this);
      this.position(e, element, widget);
      this.element.style.display = 'block';
      this.setState(true, element);
  		Stixy.events.observe(this.link, "mousedown", this.navigateLink.b(this));
      Stixy.events.observe(document, "mousemove", hideEvent);
    },
  	hide: function(){
      this.element.style.display = 'none';
      this.setState(false, null);
      Stixy.events.stopObserving(this.link, "mousedown", this.navigateLink.b(this));
    },
    editLink: function(e){
      Stixy.events.stop(e);
      this.announce('editclick', e, this.link, this.href, this.label)
    },
    navigateLink: function(e){
      Stixy.events.stop(e);
      this.announce('linkclick', e, this.link, this.href)
    },
    position: function(e, element, widget){
      // Cursor offset
      var offsetX = e.clientX + Stixy.ui.canvas.scrollLeft - Stixy.element.positionedOffset(this.source, 'offsetLeft');
      var offsetY = e.clientY + Stixy.ui.canvas.scrollTop - Stixy.element.positionedOffset(this.source, 'offsetTop');

      // Cursor offset to element when registred by the event
      var regX = offsetX - Stixy.element.positionedOffset(element, 'offsetLeft', this.source);
      var regY = offsetY - Stixy.element.positionedOffset(element, 'offsetTop', this.source);

      // Alter position if the position is registered more than 5 px from top/left
      offsetX -= (regX > 5) ? 10 : 0 ;
      offsetY -= (regY > 5) ? 5 : -5 ;

      this.element.style.left = offsetX + "px";
      this.element.style.top  = offsetY + "px";
    },
    setState: function(state, element){
      this.visible = state;
      this.currentElement = element;
    },
    getState: function(element){
      return this.visible && this.currentElement && this.currentElement == element;
    }

  });

  var editor = new function(){
    this.storedSelection = null;
    this.updated = false;
  	this.initiating = false;
  	this.listen("create", function(){ this.initiating = false }.b(this))
  	this.listen("beforeopen", function(){ this.initiating = true }.b(this));
    var update, element;
    this.update = function(){
      if(this.updated==false){
  			this.announce("beforeedit");
        this.updated = true;
      }
    }
    this.updateSize = function(event){ }
    this.getSelection = function(){
      var selection = window.getSelection();
      var source = this.source
      function getNodeIndex(node){
        var index, indexlist = [];
        while(node && (node != source)){
          index = 0;
          while(node.previousSibling){
            index++;
            node = node.previousSibling;
          }
          indexlist.push(index);
          node = node.parentNode;
        }
        return indexlist
      }
  		this.storedSelection = {};
      this.storedSelection.startIndex  = (selection.anchorNode)   ? getNodeIndex(selection.anchorNode).reverse() : [this.source.childNodes.length-1];
      this.storedSelection.startOffset = (selection.anchorOffset) ? selection.anchorOffset : 0;
      this.storedSelection.lastIndex   = (selection.focusNode)    ? getNodeIndex(selection.focusNode).reverse() : [this.source.childNodes.length-1];
      this.storedSelection.lastOffset  = (selection.focusOffset)  ? selection.focusOffset : 0;
    }
    this.deleteSelection = function(event){
  		if((!event.ctrlKey) && (!event.altKey) && (!event.metaKey) && (!event.shiftKey)){
  			if(event.type=="keydown" && !this.selection.isCollapsed){
  				if(event.charCode>=0) { 
  					this.selection.deleteFromDocument() 
  					this.selection.collapse(this.selection.focusNode, this.selection.focusOffset)
  				}
  				this.window.contentWindow.removeEventListener("keydown",  this.eventDeleteSelection, true);
  			}else if(event.type=="press" && !this.selection.isCollapsed){
  				if(event.keyCode==0||event.keyCode==46||event.which==8){
  					if(event.keyCode==46||event.which==8){
  						event.preventDefault();
  						event.stopPropagation();
  					}
  					this.selection.deleteFromDocument();
  				}
  				this.selection.collapse(this.selection.focusNode,this.selection.focusOffset);
  				delete this.selection;
  				this.window.contentWindow.removeEventListener("keypress", this.eventDeleteSelection, true);
  			}else{
  				if(event.keyCode==46||event.which==8){
  					event.preventDefault();
  					event.stopPropagation();
  				}
  				delete this.selection;
  				this.window.contentWindow.removeEventListener("keydown",  this.eventDeleteSelection, true);
  				this.window.contentWindow.removeEventListener("keypress", this.eventDeleteSelection, true);
  			}
  		}
  	}
    this.setSelection = function(){
  		var textRange = document.createRange();
      this.selection = this.window.contentWindow.getSelection();
  		if(this.body.innerHTML == '<font size="3"></font>'){
        var breakTag = document.createElement("br");
  			var fontTag = this.body.getElementsByTagName("font")[0];
        var spacer = fontTag.appendChild(document.createTextNode("."));
        var breaker = fontTag.appendChild(breakTag);
        textRange.setStart(spacer,0);
        textRange.setEnd(spacer,0);
        this.selection.addRange(textRange);
        this.selection.collapseToEnd();
  			spacer.deleteData(0,1);
  		}else{
  			function getNodeFromIndex(indexlist, node){
  				if(!node) { return }
  				while(indexlist.length>0 && node){
  					node = node.childNodes[indexlist.shift()];
  				}
  				return node;
  			}
  			var start = getNodeFromIndex(this.storedSelection.startIndex, this.body);
  			var last = getNodeFromIndex(this.storedSelection.lastIndex, this.body);
  			if(!start || !last) { return }
  			textRange.setStart(start,this.storedSelection.startOffset);
  			// We need to add a range and then collapse it to get around a bug in Firefox that causes
  			// an error when trying to check a command state on an added range
  			this.selection.addRange(textRange);
  			this.selection.collapseToEnd();
  			if(!(start==last&&this.storedSelection.startOffset==this.storedSelection.lastOffset)){
  				this.selection.addRange(textRange);
  				this.selection.extend(last,this.storedSelection.lastOffset)
  			}
  			this.eventDeleteSelection = this.deleteSelection.b(this)
  			this.window.contentWindow.addEventListener("keypress",  this.eventDeleteSelection, true);
  			this.window.contentWindow.addEventListener("keydown",  this.eventDeleteSelection, true);
  			this.storedSelection = null;
      }
  		setTimeout(function(){
  			this.setEditorFocus()
  			this.announce("textselected");
  		}.b(this), 1);
    }
    this.styleEditContent = function(){
      var sourceStyle = document.defaultView.getComputedStyle(this.source,null);
      function propertyTest(name){
        switch(name){
          case "position"||"top"||"right"||"bottom"||"left"||"width"||"height"||"clear"||
               "float"||"max-height"||"max-width"||"min-height"||"min-width"||"z-index": return true;
          default: return false;
        }
      }
      for(var i=0; i<sourceStyle.length; i++){
        var propertyName = sourceStyle.item(i);
        var propertyValue = sourceStyle.getPropertyValue(propertyName, null);
        if(propertyTest(propertyName)) {
          this.window.style.setProperty(propertyName, propertyValue, null);
        } else {
          this.body.style.setProperty(propertyName, propertyValue, null);
  			}
      }
    }
    this.destroy = function(){
  		if(this.window){
  		  if(this.body){
  				this.populateSource();
  		    this.body.removeEventListener("mouseup",this.eventTextSelected , true);
  			}
  	    if(this.window.contentWindow) {
  				//this.window.contentWindow.removeEventListener("keyup", this.eventKeyUp, true)
  			}
  			this.source.parentNode.removeChild(this.window);
  		  this.window = null;
  			this.announce("destroy");
  		}
  	}
  	this.setEditorFocus = function(){
  		if(this.window && (this.window.contentWindow)) { this.window.contentWindow.focus() }
  	}
    this.populateSource = function(){
  		while(this.body.hasChildNodes()) {
      	this.source.appendChild(this.body.firstChild);
  		}
      this.window.className = "editor-window-init";
      this.source.style.display = "block";
    }
    this.populateEditor = function(){
      if(this.window){
  			this.announce("beforepopulateeditor")
  	    this.body.innerHTML = ""
        while(this.source.hasChildNodes()) {
        	this.body.appendChild(this.source.firstChild);
  			}
        if(this.body.firstChild){
          if(this.body.firstChild.nodeType==1 && this.body.firstChild.getAttribute("_moz_editor_bogus_node")){
            this.body.removeChild(this.body.firstChild);
          }
        }
        this.source.style.display = "none";
        this.body.className = "editor-document";
        this.window.className = "editor-window";
  			this.setSelection();
        this.selection = this.window.contentWindow.getSelection();
      }
    }
    this.create = function(){
      this.window = document.createElement("iframe");
      this.window.className = "editor-window-init";
      if(this.source.nextSibling){
        this.source.parentNode.insertBefore(this.window, this.source.nextSibling);
      }else{
        this.source.parentNode.appendChild(this.window);
      }
      with(this.window.contentDocument){
        designMode = "on";
  			execCommand('enableInlineTableEditing', false, "false");
  	    execCommand('enableObjectResizing', false, "false");
  			execCommand("styleWithCSS", false, null);
  			// It's needed to open, write, and close the document to make it all work. 
  			// The . (period) needs to be erased before the real content is added to the body.
        open();
  			write(".")
        close();
      }
  		var style = this.window.contentDocument.firstChild.firstChild.appendChild(document.createElement("style"))
  		var s = parent.document.styleSheets;
  		var sl = s.length;
  		try{
  			for(var i=0; i<sl; i++){
  				var r = document.styleSheets[i].cssRules;
  				var rl = r.length;
  				for(var x=0; x<rl; x++){
  					this.window.contentDocument.styleSheets[0].insertRule(r[x].cssText.replace(/(^|\s|\})sx:/g,"$1sx\\:"),null)
  				}
  			}
  		}catch(e){ }
      this.body = this.window.contentDocument.firstChild.lastChild;
  		this.eventTextSelected = function(){
  			this.selection = this.window.contentWindow.getSelection();
  			this.announce("textselected");
      }.b(this);
      this.body.addEventListener("mouseup",this.eventTextSelected , true);
    }
  	this.eventKeyUp = this.update.b(this);
    this.init = function(){
      this.announce("beforecreate");
  		this.create();
  		this.styleEditContent();
  		this.source.style.display = "none";
      setTimeout(function(){
  			this.populateEditor();
  			this.announce("create");
  		}.b(this), 10);
  		update = this.eventKeyUp
  		element = this.window.contentWindow;
      this.window.contentWindow.addEventListener("keyup", this.eventKeyUp, true);
    }
    this.open = function(source, widget){
      this.announce("beforeopen");
  		if(this.window) {
        this.destroy();
  		}
      this.source = source;
      this.widget = widget;
  		this.getSelection();
      this.updated = false;
  		this.init();
    }
  }
  
  var activeElementInitiated;
  
  // Public instance methods
  Stixy.extend(Text.prototype, {
    reformatMozBogusNode  : reformatMozBogusNode,
    getRange              : getRange            ,
    getDocument           : getDocument         ,
    moveSelectionTo       : moveSelectionTo     ,
    trimSelection         : trimSelection       ,
    selectionToRange      : selectionToRange    ,
    rangeToSelection      : rangeToSelection    ,
    getSelection          : getSelection        ,
    focus                 : focus               ,
    findNode              : findNode            ,
    findNodeBelow         : findNodeBelow       ,
    findNodeAbove         : findNodeAbove       ,
    findParentNode        : findParentNode      ,
    findNodeInside        : findNodeInside      ,
    findSiblingNode       : findSiblingNode     ,
    findSiblingNodeAt     : findSiblingNodeAt   ,
    findChildNode         : findChildNode       ,
    findTextNode          : findTextNode        ,
    isTextNode            : isTextNode          ,
    isElementNode         : isElementNode       ,
    getEditorValues       : getEditorValues     ,
    setEditorValues       : setEditorValues     ,
    resetFormating        : resetFormating      ,
    getSelectionNodes     : getSelectionNodes   ,
    selectElementText     : selectElementText   ,
    selectTextNode        : selectTextNode      ,
    replaceText           : replaceText         ,
    getText               : getText             ,
    nextNode              : nextNode            ,
    selectWord            : selectWord          ,
    collapseSelection     : collapseSelection   ,
    editLink              : editLink            ,
    validURL              : validURL            ,
    openEditLinkPopup     : openEditLinkPopup   ,
    editor                : editor           
  });
  
  return Text;
})();