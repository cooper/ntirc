NodeList.prototype.each = Array.prototype.each = function (func) {
    var thisp = arguments[1];
    for (var i = 0; i < this.length; i++) {
        if (i in this)
            func.call(thisp, this[i], i, this);
    }
};

// first child of class type
Element.prototype.getC = function (classtype) {
    return this.getElementsByClassName(classtype)[0];
};


function $ (id) {
    return document.getElementById(id);
}

function $$ (id) {
    return document.getElementsByClassName(id);
}

function $element (type) {
    return document.createElement(type);
}
