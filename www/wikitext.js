function wikitext(textArray, domNode) {
    console.log("text", textArray);
    console.log("domNode", domNode);
    textArray.forEach (e => {
	var elementKeys = Object.keys(e);
	elementKeys.forEach (k => {
	    console.log("k", k);
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
    wikitext(content, domNode);
}

document.addEventListener("DOMContentLoaded", _ => {
    jsonWiki(json_doc, document.querySelector(".wikitext"));
});
