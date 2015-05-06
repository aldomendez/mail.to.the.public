var push = require( 'pushover-notifications' );

var p = new push( {
    user: process.env['PUSHOVER_USER'],
    token: process.env['PUSHOVER_TOKEN'],
    // onerror: function(error) {},
    // update_sounds: true // update the list of sounds every day - will
    // prevent app from exiting.
});

var msg = {
    // These values correspond to the parameters detailed on https://pushover.net/api
    // 'message' is required. All other values are optional.
    message: 'omg node test',   // required
    title: "Well - this is fantastic",
    sound: 'magic',
    device: 'devicename',
    priority: 1
};

p.send( msg, function( err, result ) {
    if ( err ) {
        throw err;
    }

    console.log( result );
});