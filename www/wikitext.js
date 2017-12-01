function wikiText(textArray, domNode) {
    textArray.forEach (e => {
	var elementKeys = Object.keys(e);
	elementKeys.forEach (k => {
	    var element = document.createElement(k);
	    element.innerText = e[k];
	    document.importNode(element);
	    domNode.appendChild(element);
	});
    });
}

function jsonWiki (jsonText, domNode) {
    const doc = JSON.parse(jsonText);
    const content = doc.content;
    wikiText(content, domNode);
}

document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
});
