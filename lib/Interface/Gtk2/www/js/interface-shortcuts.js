function navigate (type) {
    if (!focusedView) return;

    // fake mouse click event
    var evt = document.createEvent("MouseEvents");
    evt.initMouseEvent("click", true, true, window,
        0, 0, 0, 0, 0, false, false, false, false, 0, null);

    // it could be a channel, query, or server(?)
    var next = focusedView.tab[type + 'ElementSibling'];
    if (next) {
        if (next.classList.contains('channel') ||
          next.classList.contains('query')     ||
          next.classList.contains('server')) {

            // fake mouse click event
            next.dispatchEvent(evt);
        }
        else if (next.classList.contains('server-store')) {
            var fakeNext = type == 'next' ? next.firstElementChild : next.lastElementChild;
            if (!fakeNext) return; // idk
            if (fakeNext.classList.contains('channel') ||
              fakeNext.classList.contains('query'))
                fakeNext.dispatchEvent(evt);
            return;
        }
    }

    // no next sibling means we are at the end of a server-store.
    else {
        // try the next tab..
        var fakeNext = focusedView.tab.parentElement[type + 'ElementSibling'];
        if (!fakeNext) return; // idk

        // is it a server?
        if (fakeNext.classList.contains('server'))
            fakeNext.dispatchEvent(evt);

        // not a server, so maybe it's a server-store..
        // XXX not sure if this code is necessary or not
        else if (fakeNext.classList.contains('server-store')) {
            var veryFakeNext = type == 'next' ? next.firstElementChild : next.lastElementChild;
            if (!veryFakeNext) return; // idk
            if (veryFakeNext.classList.contains('channel') ||
              veryFakeNext.classList.contains('query'))
                veryFakeNext.dispatchEvent(evt);
            return;
        }
    }
}

// convenience select next tab
shortcut.add('Ctrl+Down', function () { navigate('next');     });
shortcut.add('Ctrl+Up',   function () { navigate('previous'); });
