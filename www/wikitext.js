import edit from "./wikiedit.js";

function wikiText(textArray, domNode) {
    textArray.forEach (e => {
        console.log("e is", e);
        if (typeof e === "string") {
            console.log("e is a string", e);
            let textNode = document.createTextNode(e);
            domNode.appendChild(textNode);
        }
        else {
	    var elementKeys = Object.keys(e);
	    elementKeys.forEach (k => {
                console.log("k is", k, e[k], Array.isArray(e[k]));
	        var element = document.createElement(k);
                if (Array.isArray(e[k])) {
                    wikiText(e[k], element);
                }
                else if (typeof e[k] === "object") {
                    Object.keys(e[k]).forEach(n => {
                        if (n == "_") {
                            wikiText([e[k][n]], element);
                        }
                        else {
                            element.setAttribute(n, e[k][n]);
                        }
                    });
                }
                else  {
	            element.innerText = e[k];
	            document.importNode(element, true);
                }
	        domNode.appendChild(element);
	    });
        }
    });
}

function jsonWiki (jsonText, domNode) {
    console.log("jsonText", jsonText);
    let doc = JSON.parse(jsonText);
    let form = document.querySelector(".editor");
    let nameInput = form.querySelector("input[name='name']");
    let textArea = form.querySelector("textarea");
    
    if (doc.hasOwnProperty("content")) {
        let content = doc.content;
        wikiText(content, domNode);
        textArea.value = JSON.stringify(content, null, 2);
    }

    if (doc.hasOwnProperty("name")) {
        let name = doc.name;
        nameInput.value = doc.name;
    }

    form.addEventListener("submit", function (evt) {
	let textarea = evt.target.elements["wikitext"];
	let wikitext = textarea.value;
	try {
	    JSON.parse(wikitext);
            if (nameInput.value == null) {
                throw "no doc name";
            }
            console.log("form ok!", form);
            form.submit(); // not sure why I have to do this
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

function save(jsonText) {
    let form = document.querySelector(".editor");
    form["wikitext"].value = jsonText;
    let event = new Event("submit", {target: form});
    form.dispatchEvent(event);
}

document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
    edit.keyboardInit(save);
});

// wikitext.js ends here
