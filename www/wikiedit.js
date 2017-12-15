// editor for wiki


let saveFn = function (doc) {
    console.log("no saving here", JSON.stringify(doc, null, 2));
};


let api = {
    htonChildrenToDoc: function(children) {
        let arr = Array.from(children);
        if (arr.length == 1 && !(arr[0] instanceof HTMLElement)) {
            return arr[0].textContent;
        }
        return arr.map(e => {
            // console.log("e element", e);
            if (e instanceof HTMLElement) {
                let tag = e.tagName;
                let htonObj = {};
                if (tag == "A") {
                    htonObj[tag] = { 
                        "href": e.getAttribute("href"),
                        "_": api.htonChildrenToDoc(e.childNodes)
                    };
                }
                else if (e.children.length == 0) {
                    htonObj[tag] = e.textContent;
                }
                else {
                    htonObj[tag] = api.htonChildrenToDoc(e.childNodes);
                }
                return htonObj;
            }
            else {
                return e.textContent;
            }
        });
    },

    hton: function() {
        let d = document.querySelector("div.wikitext");
        let htonDoc = api.htonChildrenToDoc(d.children);
        return htonDoc;
    },

    commit: function() {
        api.formToggle();
    },

    htonStringify: function () {
	return JSON.stringify(api.hton(), null, 2);
    },

    consoleHton: function () {
	console.log("hton>", api.htonStringify());
    },

    formToggle: function() {
        let wikitext = document.querySelector("div.wikitext");
        let toggleValue = wikitext.getAttribute("contenteditable") == "true";
        if (toggleValue) {
            keyMap.pop();
	    api.legendWikiMode();
        }
        else {
            keyMap.push(editorKeyMap);
	    api.legendEditMode();
        }
        wikitext.contentEditable = !toggleValue;
        wikitext.focus();
    },

    legendWikiMode: function () {
	document.querySelector("ul.keyHelp")
	    .innerHTML = "<li>e - enter edit mode</li>"
	    + "<li>s - save the document</li>";
    },

    legendEditMode: function () {
	document.querySelector("ul.keyHelp")
	    .innerHTML = "<li>/ - enter command mode</li>";
    },

    keyboardInit: function (saveFunction) {
        if (typeof saveFunction === "function") {
            saveFn = saveFunction;
        }

	let wikiEditor = document.querySelector("div.wikitext");
	let keyHelp = document.createElement("ul");
	keyHelp.classList.add("keyHelp");
	document.importNode(keyHelp);
	wikiEditor.parentNode.insertBefore(keyHelp, wikiEditor.nextSibling);

	api.legendWikiMode();
	
        document.onkeypress = function (evt) {
	    let key = evt.code.toLowerCase(); // not supported by edge
	    // console.log("keypress evt", key, evt);

	    if (evt.shiftKey) {
	        key = "shift_" + key;
	    }
	    if (evt.altKey) {
	        key = "alt_" + key;
	    }
	    if (evt.ctrlKey) {
	        key = "ctrl_" + key;
	    }

	    console.log("key", key, evt, keyMap);

            let keymap = keyMap[keyMap.length - 1]; // Having this indirection allows us to push new keymaps and have them used
	    let fn = keymap[key];

	    // console.log("keymap selected", key, keymap, fn);
	    if (typeof fn === "function") {
		// console.log("key>", key, fn);
	        fn();
		evt.preventDefault();
	    }
	    else {
		fn = keymap["_default"];
		if (typeof fn === "function") {
		    fn(evt);
		}
		evt.preventDefault();
	    }
        };
    },

    save: function () {
	let hton = api.htonStringify();
        saveFn(hton);
    }
};

// A keymap array that we can push keymaps onto
var keyMap = [];

let editor = {
    heading: function (level) {
        document.execCommand("formatBlock", false, "h" + level);
    },
    H1: function () {
        editor.heading(1);
    },
    H2: function () {
        editor.heading(2);
    },
    H3: function () {
        editor.heading(3);
    },
    H4: function () {
        editor.heading(4);
    },
    Para: function () {
        document.execCommand("formatBlock", false, "P");
    },
    Pre: function () {
        document.execCommand("formatBlock", false, "PRE");
    },
    List: function () {
        document.execCommand("insertUnorderedList", false, "NULL");
    },
    OrderedList: function () {
        document.execCommand("insertOorderedList", false, "NULL");
    },
    Link: function () {
        let url = prompt("What's the url?")
        document.execCommand("createLink", false, url);
    },
    Italics: function () {
	document.execCommand("italic", false, "NULL");
    },
    commandMode: function () {
	keyMap.push(editorCommandKeyMap);
	document.querySelector("ul.keyHelp")
	    .innerHTML = "<li>. - quit to edit mode</li>"
	    + "<li>q - quit edit mode to wiki mode</li>"
	    + "<li>1 - H1</li>"
	    + "<li>2 - H2</li>"
	    + "<li>3 - H3</li>"
	    + "<li>4 - H4</li>"
	    + "<li>] - make a link</li>"
	    + "<li>8 - make a list</li>"
	    + "<li>9 - make an ordered list</li>"
	    + "<li>; - make a PRE</li>"
	    + "<li>i - italics</li>"
	    + "<li>0 - P</li>";
    },
    quitCommandMode: function () {
	keyMap.pop();
	document.querySelector("ul.keyHelp")
	    .innerHTML = "<li>/ - enter command mode</li>";
    },
    quitEditor: function() {
	editor.quitCommandMode();
	api.formToggle();
    },
    insert: function (evt) {
	document.execCommand("insertText", false, evt.key);
    },
    insertSlash: function () {
	document.execCommand("insertText", false, "/");
    },
    insertPara: function () {
	document.execCommand("insertParagraph", false, "NULL");
    }
}

const editorKeyMap = {
    "slash": editor.commandMode,
    "enter": editor.insertPara,
    "_default": editor.insert
};

const editorCommandKeyMap = {
    "digit1": editor.H1,
    "digit3": editor.H3,
    "digit4": editor.H4,
    "digit0": editor.Para,
    "digit8": editor.List,
    "digit9": editor.OrderedList,
    "bracketright": editor.Link,
    "semicolon": editor.Pre,
    "period": editor.quitCommandMode,
    "keyi": editor.Italics,
    "keyq": editor.quitEditor,
    "slash": editor.insertSlash
};

keyMap.push({
    "keye": api.formToggle,
    "keys": api.save,
    "shift_slash": api.consoleHton
});

export default api;
