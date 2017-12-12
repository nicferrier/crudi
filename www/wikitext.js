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

function save(jsonText) {
    let form = document.querySelector(".editor");
    form["wikitext"].value = jsonText;
    form.submit();
}

document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
    edit.keyboardInit(save);
});

// wikitext.js ends here
