function wikiText(textArray, domNode) {
    textArray.forEach (e => {
	var elementKeys = Object.keys(e);
	elementKeys.forEach (k => {
	    var element = document.createElement(k);
	    element.innerText = e[k];
	    document.importNode(element, true);
	    domNode.appendChild(element);
	});
    });
}

function jsonWiki (jsonText, domNode) {
    let doc = JSON.parse(jsonText);
    let content = doc.content;
    wikiText(content, domNode);
    let form = document.querySelector(".editor");
    form.querySelector("textarea").value = JSON.stringify(content, null, 2);
    form.querySelector("input[name='name']").value = doc.name;
    form.addEventListener("submit", function (evt) {
	let textarea = evt.target.elements["wikitext"];
	let wikitext = textarea.value;
	try {
	    console.log("parsing it");
	    JSON.parse(wikitext);
	    return true;
	}
	catch (e) {
	    console.log("exception", e);
	    textarea.classList.add("error");
	    evt.preventDefault();
	    return false;
	}
    });
}

function* styleRules(selectorMatch) {
    for (let sheet of document.styleSheets) {
	for (let rule of sheet.cssRules) {
	    if (selectorMatch.matches(rule.selectorText)) {
		yield rule;
	    }
	}
    }
}


function htonChildrenToDoc (children) {
    return Array.from(children).map(e => {
        let tag = e.tagName;
        let htonObj = {};
        console.log("children", e.children);
        htonObj[e.tagName] = e.textContent;
        console.log("htonObj", htonObj);
        return htonObj;
    });
}

function hton () {
    let d = document.querySelector("div.wikitext");
    let htonDoc = htonChildrenToDoc(d.children);
    console.log("doc", JSON.stringify(htonDoc, null, 2));
    return htonDoc;
}

function commit() {
    console.log("commit called");
    formToggle();
    hton();
}


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
    List: function () {
        document.execCommand("insertUnorderedList", false, "NULL");
    },
    Link: function () {
        document.execCommand("createLink", false, "http://blah");
    },
}

const editorKeyMap = {
    "ctrl_shift_digit1": editor.H1,
    "ctrl_shift_digit3": editor.H3,
    "ctrl_shift_digit4": editor.H4,
    "ctrl_shift_digit0": editor.Para,
    "ctrl_shift_digit8": editor.List,
    "ctrl_shift_bracketright": editor.Link,
    "ctrl_shift_keyz": commit
};

var keyMap = [{
    "ctrl_shift_keye": formToggle,
}];

function keyboardInit () {
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
}

function formToggle () {
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
}


document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
    keyboardInit();
});

// wikitext.js ends here
