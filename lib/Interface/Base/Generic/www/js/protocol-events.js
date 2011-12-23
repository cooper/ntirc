/*
    EVENTS
    --------------------------------------------------------------------------------------

    [raw] fired immediately after a message is received from core { message: string }
    [raw_*] fired by [raw] where * is the message command { arguments: object }

*/

var proto = {
    events: {},
    id: 0,

    attachEvent: function (type, callback) {
        if (!proto.events[type]) proto.events[type] = {};
        proto.events[type][proto.id++] = callback;
        return true;
    },

    removeEvent: function (type, id) {
        if (proto.events[type][id]) {
            delete proto.events[type][id];
            return true;
        }
        return false;
    },

    clearEvent: function (type) {
        if (proto.events[type]) {
            delete proto.events[type];
            return true;
        }
        return false;
    },

    fireEvent: function (type, event) {
        Object.values(proto.events[type]).each(function (callback) {
            callback(event);
        });
        return true;
    }
};

proto.attachEvent('raw', function (message) {
    var event   = JSON.parse(message);
    var command = event.command;
    proto.fireEvent('raw_' + command, event);
});

