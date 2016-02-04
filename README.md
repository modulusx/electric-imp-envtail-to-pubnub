# Electric Imp Environmental Data Streaming through PubNub
This is a modification of the Electric Imp Environmental Data Streaming tutorial redesigned to stream through PubNub instead of InitialState.
Streaming the data through [PubNub](https://www.pubnub.com/) allows for a couple of cool features:
- The readSensors() function can now be called from any PubNub publishing client on the channel and received by any subscriber
- readSensors() only runs when a client requests it by publishing a readSensors call to imp on the action channel:
```
{"imp":"readSensors"}
```
If we add a local instance of a pretty simple python script subscribed to the status channel, we can do some other fun things:
- By logging the sensor readings into an instance of InfluxDB, we can not only graph the values with Grafana, but we can also:
- Trigger events with Kapacitor. Say, if the lux value falls under 100, let's turn on some Hue Lights.

## Some Background
### What is [PubNub](https://www.pubnub.com/)?
They've [said it best](https://www.youtube.com/watch?v=jZgcEj_qKLU) themselves:
PubNub is an Internet 2-way radio, a bidirectional json radio.

## Prerequisites
- An Electric Imp with the Env Tail
- [BlinkUp](https://electricimp.com/docs/gettingstarted/blinkup/) your Imp
- A PubNub account
- An instance of InfluxDB, Grafana, and a simple Python script to log values into InfluxDB (more on this later)

## Usage
1. Log into the [Electric Imp IDE](https://ide.electricimp.com/login) and start a new project, don't forget to assign the device to it
2. Log into PubNub and get your publish and subscribe keys
3. Copy the code from envTailAgent.nut into your Agent Pane (on the left) and update the PUBKEY and SUBKEY values
4. You can also modify the host and region tags to suit your needs
5. Copy the code from envTailDevice.nut into your Device Pane (on the right)
6. Check your code for errors, then **Build and Run**

## Testing

At this point your Imp should be running, subscribed to your PubNub channel, and ready to send sensor data when asked.

1. Open the PubNub Developer Console
2. Subscribe to both the action and status channels
3. Publish **{"imp":"readSensors"}** to the action channel, you might need to escape the quotes
```
{\"imp\":\"readSensors\"}
```
The status channel should then output the json as received from your imp:
```
{
  "fields": {
    "press": 1032.38,
    "temp": 66.6285,
    "lux": 106.476,
    "humid": 42.1529
  },
  "measurement": "environmental",
  "time": "2016-2-4T0:25:23Z",
  "tags": {
    "region": "home01",
    "host": "imp01"
  }
}
```

## Credits to InitialState and Electric Imp for making this so easy

Here you will find the original code materials for the initalstate tutorial as well as the tutorial itself in the [wiki](https://github.com/InitialState/electric-imp-streaming/wiki).
The [blog post](http://blog.initialstate.com/tutorial-electric-imp-streamer/) for completeness.
