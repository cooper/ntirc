function insertJavaScript (js) {
    var script = $element('script');
    script.setAttribute('type', 'text/javascript');
    script.innerHTML = js;
    document.head.appendChild(script);
}

function insertStyleSheet (css) {
    var style = $element('style');
    style.setAttribute('type', 'text/css');
    style.innerHTML = css;
    document.head.appendChild(style);
}

function insertHTML (html) {
    $('body').innerHTML = html;
}
