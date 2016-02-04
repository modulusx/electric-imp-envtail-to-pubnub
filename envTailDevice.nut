#require "Si702x.class.nut:1.0.0"
#require "APDS9007.class.nut:1.0.0"
#require "LPS25H.class.nut:1.0.0"

// Establish a global variable to hold environmental data
data <- {};
data.temp <- 0;
data.humid <- 0;
data.pressure <- 0;
data.lux <- 0;

// Instance the Si702x and save a reference in tempHumidSensor
hardware.i2c89.configure(CLOCK_SPEED_400_KHZ);
local tempHumidSensor = Si702x(hardware.i2c89);

// Instance the LPS25H and save a reference in pressureSensor
local pressureSensor = LPS25H(hardware.i2c89);
pressureSensor.enable(true);

// Instance the APDS9007 and save a reference in lightSensor
local lightOutputPin = hardware.pin5;
lightOutputPin.configure(ANALOG_IN);

local lightEnablePin = hardware.pin7;
lightEnablePin.configure(DIGITAL_OUT, 1);

local lightSensor = APDS9007(lightOutputPin, 47000, lightEnablePin);

// Configure the LED (on pin 2) as digital out with 0 start state
local led = hardware.pin2;
led.configure(DIGITAL_OUT, 0);

// This function will be called regularly to take the temperature,
// light, humidity, and pressure and log it to the device’s agent

function readSensors() {
    // Flash the LED
    flashLed();
    
    // Get the light level
    data.lux = lightSensor.read();
    
    // Get the pressure. This is an asynchronous call, so we need to 
    // pass a function that will be called only when the sensor 
    // has a value for us.
    pressureSensor.read(function(pressure) {
        data.pressure = pressure;
        
        // Now get the temperature and humidity. Again, this is an
        // asynchronous call: we need to a pass a function to be
        // called when the data has been returned. This time
        // the callback function also has to bundle the data
        // and send it to the agent. Then it puts the device into
        // deep sleep until it's next time for a reading.
        tempHumidSensor.read(function(reading) {
            data.temp = reading.temperature;
            data.humid = reading.humidity;
            
            // Send the data to the agent
            agent.send("sensors", data);
        });
    });
}

function flashLed() {
    // Turn the LED on (write a HIGH value)
    led.write(1);
    
    // Pause for half a second
    imp.sleep(0.25);
    
    // Turn the LED off
    led.write(0);
}

// Set the LED when the agent requests it
agent.on("action", function(state) {
  switch(state) {
    case "ledOff":
      led.write(0);
      break;
    case "ledOn":
      led.write(1);
      break;
    case "readSensors":
      readSensors();
    default:
      flashLed();
      break;
  }
});
