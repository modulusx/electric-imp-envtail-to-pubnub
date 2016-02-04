#require "PubNub.class.nut:1.1.0"

// Establish a local variable to hold environmental data
local lastReading = {};
lastReading.pressure <- 1013.25;
lastReading.temp <- 22;
lastReading.lux <- 300;
lastReading.humid <- 0;

// PubNub Publish and Subscribe Keys
const PUBKEY = "pub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
const SUBKEY = "sub-c-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";

statusChannel <- "home-status";
actionChannel <- "home-action";

pubnub <- PubNub(PUBKEY, SUBKEY);

pubnub.subscribe([actionChannel], function(err, result, tt) {
    if(result != null && actionChannel in result) {
        try {
            local data = http.jsondecode(result[actionChannel]);
            if ("imp" in data) {
                device.send("action", data["imp"]);
            }
        } catch(ex) {
            server.log("Error - " + ex);
        }
    }
});

function handleSensors(reading) {
    // Note: reading is the data passed from the device, ie.
    // a Squirrel table with the key 'temp'
    
    local now = date();
    local timeString = now.year + "-" + (now.month + 1) + "-" + now.day + "T" +
    now.hour + ":" + now.min + ":" + now.sec + "Z";
    
    local sensorStatus = {
        "measurement": "environmental",
        "tags": {
            "host": "imp01",
            "region": "home01"
        },
        "time": timeString,
        "fields": {
            "temp": (reading.temp.tofloat()* 9 / 5) + 32,
            "humid": reading.humid,
            "press": reading.pressure,
            "lux": reading.lux
        }
    };
    
    // Send an array of events to PubNub Status Channel
    pubnub.publish(statusChannel, sensorStatus);
    
    lastReading = reading;
}

// Register the function to handle data messages from the device
device.on("sensors", handleSensors);
