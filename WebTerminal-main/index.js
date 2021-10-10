/*
GitHub : https://github.com/niirmaaltwaatii/WebTerminal/
*/

const dark = "#333333";
const white = "#ffffff";
const lime = "#00ff00";

var elms = [
    "body",
    "div",
    "p",
    // "span",
    // "input",
    "section",
    "ul",
    "li"
]

for(let j=0; j < elms.length; j++){
    var elm = document.getElementsByTagName(elms[j]);
    for(let i=0; i < elm.length; i++){
        var el = elm[i];
        el.style.backgroundColor = dark;
        el.style.color = white;
    }
}


var lnks = document.getElementsByTagName("a");
for(let i=0; i < lnks.length; i++){
    var lnk = lnks[i];
    lnk.style.color = lime;
}

var cites = document.getElementsByTagName("cite");
for(let i=0; i < cites.length; i++){
    var cite = cites[i];
    cite.style.color = "red";
}

var inps = document.getElementsByTagName("input");
for(let i=0; i < inps.length; i++){
    var inp = inps[i];
    inp.style.backgroundColor = "grey";
    inp.style.color = lime;
    inp.style.fontWeight = "bolder";
    if(inp.type == "submit"){
        //inp.style.color = white;
    }
}