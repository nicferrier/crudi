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

function formToggle () {
    // could turn this into a generator that flattens all style rules?
    let matcher = {matches: function (t) { return t == ".editor";}};
    for (let rule of styleRules(matcher)) {
	let state = rule.style.display;
	if (state == "block") {
	    rule.style.display = "none";
	}
	else {
	    rule.style.display = "block";
	}
    }
}

function keyboardInit (keyMap) {
    document.onkeypress = function (evt) {
	let key = evt.key ? evt.key : String.fromCharCode(evt.charCode? evt.charCode : evt.keyCode);
	if (evt.shiftKey) {
	    key = "shift_" + key.toLowerCase();
	}
	if (evt.altKey) {
	    key = "alt_" + key;
	}
	if (evt.ctrlKey) {
	    key = "ctrl_" + key;
	}

	// console.log("key", key, evt);

	let fn = keyMap[key];
	if (typeof fn === "function") {
	    fn();
	}
    };
}

document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
    keyboardInit({
	"ctrl_shift_e": formToggle
    });
});

// wikitext.js ends here
