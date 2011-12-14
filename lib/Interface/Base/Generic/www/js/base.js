// first child of class type
Element.prototype.getC = function (classtype) {
    return this.getElementsByClassName(classtype)[0];
};

function $element (type) {
    return document.createElement(type);
}
