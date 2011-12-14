var views       = {},
    msgId       = 0,
    lastDimen   = '0';
    focusedView = undefined;

document.addEventListener('DOMContentLoaded', function () {

});

window.onresize = function () {
    $('body').style.height = innerHeight - 2 + 'px';

    // resizes buffer and userlist so that textbox doesn't overlap it
    $$('.buffer').each(function (buffer) {
        buffer.style.height = '100%';
        buffer.style.height = buffer.clientHeight - buffer.parentElement.getC('topicbar').offsetHeight
                            + 1 // XXX assumes that the top border of the topicbar is 1px
                            - buffer.parentElement.getC('inputbox').offsetHeight + 'px';
        buffer.scrollTop    = buffer.scrollHeight;

    });
    $$('.inputbox').each(function (input) {
        input.style.width = input.parentElement.getC('buffer').offsetWidth + 'px';
    });

};

function getColor (color) {
    var n = '#fff';
    switch (parseInt(color)) {
        case 12: n = 'royalblue';  break;
        case 4:  n = 'red';        break;
        case 9:  n = 'lightgreen'; break;
        case 2:  n = 'blue';       break;
        case 3:  n = 'green';      break;
        case 13: n = 'hotpink';    break;
        case 11: n = 'turquoise';  break;
        case 10: n = 'teal';       break;
        case 6:  n = 'purple';     break;
    }
    return 'color: ' + n;
}

function readyForHTML (string) {
    while (string.match(/\s/)) { // note: /g won't work
        string = string.replace(/\s/, '&nbsp;');
    }
    string = string.replace(/\</g, '&lt;');
    string = string.replace(/\>/g, '&gt');

    return string;
}

function createServer (id, name) {
    var tab       = $element('div');
    tab.innerText = name;
    tab.setAttribute('class', 'server');
    tab.setAttribute('id', '-server-' + id);
    tab.addEventListener('click', function () { focusServer(id); });
    $('sidebar').appendChild(tab);

    var store     = $element('div');
    store.classList.add('server-store');
    store.setAttribute('id', '-server-store-' + id);
    $('sidebar').appendChild(store);

    var view = $element('div');
    view.setAttribute('class', 'textarea');
    view.setAttribute('id', '-view-server-' + id);
    view.hidden = true;
    $('main').appendChild(view);
    views[id] = { server: view };
}

function createChannel (servId, name) {

    // create a tab
    var tab       = $element('div');
    tab.innerText = name;
    tab.setAttribute('class', 'channel');
    tab.setAttribute('id', '-channel-' + servId + '-' + name);
    tab.addEventListener('click', function () { focusChannel(servId, name); });
    $('-server-store-' + servId).appendChild(tab);
    reorderServerStore(servId);

    // create a view
    var view = $element('div');
    view.setAttribute('class', 'textarea');
    view.setAttribute('id', '-view-channel-' + servId + '-' + name);
    view.hidden = true;
    $('main').appendChild(view);


    // create a userlist
    var userlist = $element('div');
    userlist.setAttribute('id', '-user-list-' + servId + '-' + name);
    userlist.setAttribute('class', 'userlist');
    view.appendChild(userlist);

    // nick count at top of userlist
    var nickcount = $element('div');
    nickcount.setAttribute('class', 'nickcount');
    userlist.appendChild(nickcount);
    nickcount.innerText = '0 users'; // XXX

    // topic bar
    var topic = $element('div');
    topic.setAttribute('id', '-topic-bar-' + servId + '-' + name);
    topic.setAttribute('class', 'topicbar');
    view.appendChild(topic);

    // buffer (scrollable container)
    var buffer = $element('div');
    buffer.setAttribute('class', 'buffer');
    view.appendChild(buffer);

    // table
    var table = $element('table');
    table.setAttribute('class', 'message-table');
    buffer.appendChild(table);

    // input textbox
    var input = $element('input');
    input.setAttribute('type', 'text');
    input.setAttribute('class', 'inputbox');
    view.appendChild(input);

    // blink textbox border on scroll to bottom
    buffer.addEventListener('scroll', function () {
        var scrollBottom = !(buffer.scrollHeight - (buffer.scrollTop + buffer.clientHeight));
        if (scrollBottom) {
            if (view.retrieve('scrollBottom')) return;
            view.store('scrollBottom', true);
            input.className += ' bottom';
            setTimeout(function () { input.className = input.className.replace('bottom', ''); }, 500);
        }
        else {
            view.store('scrollBottom', false);
        }
    });

    views[servId]['channel-' + name] = view;

    channelNotify(servId, name, 'join', 'Now talking on ' + name);
}

function focusServer (servId) {
    if (focusedView && focusedView.view) focusedView.view.hidden = true;
    var view    = views[servId].server;
    var tab     = $('-server-' + servId);
    view.hidden = false;
    tab.className += ' active';

    if (focusedView) {
        focusedView.tab.className = focusedView.tab.className.replace('active', '');
    }

    focusedView = {
        view: view,
        tab: tab,
        name: tab.innerText
    };

    window.onresize();
}

// for both users and queries
function scrollToBottomIfNecessary (view, msgBox) {
    var buffer       = view.getC('buffer');
    var scrollBottom = buffer.scrollHeight - (buffer.scrollTop + buffer.clientHeight);
    var uneven       = scrollBottom - msgBox.offsetHeight;
    if (!uneven) buffer.scrollTop = buffer.scrollHeight;
}

function addUserToChannel (servId, channelName, nick) {
    var userlist  = $('-user-list-' + servId + '-' + channelName);
    var nickcount = userlist.getC('nickcount');

    var user = $element('div');
    user.store('status', -Infinity);
    user.setAttribute('id', '-user-' + servId + '-' + channelName + '-' + nick);
    user.setAttribute('class', 'user');
    user.innerText = nick;
    userlist.appendChild(user);

    nickcount.innerText = userlist.children.length - 1 + ' users';
    reorderChannelUserList(servId, channelName);
}

function focusChannel (servId, name) {
    if (focusedView && focusedView.view) focusedView.view.hidden = true;
    var view    = views[servId]['channel-' + name];
    var tab     = $('-channel-' + servId + '-' + name);
    view.hidden = false;
    tab.className += ' active';

    if (focusedView) {
        focusedView.tab.className = focusedView.tab.className.replace('active', '');
    }

    focusedView = {
        view: view,
        tab: tab,
        name: name
    };

    window.onresize();
    view.getC('inputbox').focus();
}

function setChannelTopic (servId, channelName, newtopic) {
    var topic = $('-topic-bar-' + servId + '-' + channelName);
    topic.innerText = newtopic;
}

function insertMsg (servId, channelName, from, msg) {

    var id = ++msgId;

    var tr = document.createElement('tr');

    var nick = document.createElement('td');
    nick.setAttribute('class', 'nick');
    nick.setAttribute('id', '-msg-' + id + '-nick');
    nick.innerHTML = '<span class="invisible">&lt;</span>'
                    + from
                    + '<span class="invisible">&gt;</span>';
    tr.appendChild(nick);

    var msgBox = document.createElement('td');
    msgBox.innerHTML   = readyForHTML(msg);
    msgBox.setAttribute('class', 'message');
    msgBox.setAttribute('id', '-msg-' + id + '-message');
    tr.appendChild(msgBox);

    var view = views[servId]['channel-' + channelName];

    view.getC('message-table').appendChild(tr);

    scrollToBottomIfNecessary(view, msgBox); 
}

function insertAction (servId, channelName, from, msg) {

    var id = ++msgId;

    var tr = document.createElement('tr');

    var nick = document.createElement('td');
    nick.classList.add('asterisk');
    nick.setAttribute('id', '-msg-' + id + '-nick');
    nick.innerText = '*';
    tr.appendChild(nick);

    var msgBox = document.createElement('td');
    msgBox.innerHTML   = from + ' ' + readyForHTML(msg);
    msgBox.classList.add('action');
    msgBox.setAttribute('id', '-msg-' + id + '-message');
    tr.appendChild(msgBox);

    var view = views[servId]['channel-' + channelName];

    view.getC('message-table').appendChild(tr);

    scrollToBottomIfNecessary(view, msgBox); 
}

function channelNotify (servId, channelName, type, msg) {

    var id = ++msgId;

    var tr = document.createElement('tr');

    var nick = document.createElement('td');
    nick.classList.add('asterisk');
    nick.setAttribute('id', '-msg-' + id + '-nick');
    nick.innerText = '*';
    tr.appendChild(nick);

    var msgBox = document.createElement('td');
    msgBox.innerHTML = readyForHTML(msg);
    msgBox.classList.add('channel-notify-' + type);
    msgBox.classList.add('channel-notify');
    msgBox.setAttribute('id', '-msg-' + id + '-message');
    tr.appendChild(msgBox);

    var view = views[servId]['channel-' + channelName];
    view.getC('message-table').appendChild(tr);

    scrollToBottomIfNecessary(view, msgBox);    
}

function setChannelUserStatus (servId, channelName, nick, status) {
    var user = $('-user-' + servId + '-' + channelName + '-' + nick);
    if (!user) return;
    user.classList.add('user-status-' + status);

    // TODO remove old class

    user.store('status', status);
    reorderChannelUserList(servId, channelName);
}

function reorderChannelUserList (servId, channelName) {
    var userlist = $('-user-list-' + servId + '-' + channelName);
    if (!userlist) return;
    var users = Array.from(userlist.getElementsByClassName('user'));

    // start fresh and put the users into groups by their status.
    var userGroups = {};
    users.each(function (user) {
        userlist.removeChild(user);
        if (!userGroups[user.retrieve('status')]) userGroups[user.retrieve('status')] = [];
        userGroups[user.retrieve('status')].push(user);
    });

    // now sort each group alphabetically
    Array.each(Object.keys(userGroups).sort(function (a, b) {
        return b - a;
    }), function (level) {
        userGroups[level].sort(function (a, b) {
            return a.innerText.toLowerCase() > b.innerText.toLowerCase() ? 1 : -1;
        }).each(function (user) {
            userlist.appendChild(user);
        });
    });
}

function reorderServerStore (servId) {
    var store = $('-server-store-' + servId);
    if (!store) return;
    var things = Array.clone(store.children);
    things.each(function (thing) { store.removeChild(thing); });
    things.sort(function (a, b) {
        return a.innerText.toLowerCase() > b.innerText.toLowerCase() ? 1 : -1;
    }).each(function (thing) {
        store.appendChild(thing);
    });
}
