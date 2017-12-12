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
}

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
            console.log("e element", e);
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

    formToggle: function() {
        let wikitext = document.querySelector("div.wikitext");
        let toggleValue = wikitext.getAttribute("contenteditable") == "true";
        if (toggleValue) {
            keyMap.pop();
        }
        else {
            keyMap.push(editorKeyMap);
        }
        wikitext.contentEditable = !toggleValue;
        wikitext.focus();
    },

    keyboardInit: function (saveFunction) {
        if (typeof saveFunction === "function") {
            saveFn = saveFunction;
        }
        document.onkeypress = function (evt) {
	    let key = evt.code;
	    if (evt.shiftKey) {
	        key = "shift_" + key.toLowerCase();
	    }
	    if (evt.altKey) {
	        key = "alt_" + key;
	    }
	    if (evt.ctrlKey) {
	        key = "ctrl_" + key;
	    }

	    console.log("key", key, evt);

            let keymap = keyMap[keyMap.length - 1]; // Having this indirection allows us to push new keymaps and have them used
	    let fn = keymap[key];
	    if (typeof fn === "function") {
	        fn();
	    }
        };
    },

    save: function () {
        saveFn(JSON.stringify(api.hton(), null, 2));
    }
};


const editorKeyMap = {
    "ctrl_shift_digit1": editor.H1,
    "ctrl_shift_digit3": editor.H3,
    "ctrl_shift_digit4": editor.H4,
    "ctrl_shift_digit0": editor.Para,
    "ctrl_shift_digit8": editor.List,
    "ctrl_shift_digit9": editor.OrderedList,
    "ctrl_shift_bracketright": editor.Link,
    "ctrl_shift_semicolon": editor.Pre,
    "ctrl_shift_keyz": api.commit
};

var keyMap = [{
    "ctrl_shift_keye": api.formToggle,
    "ctrl_shift_period": api.save
}];

export default api;
