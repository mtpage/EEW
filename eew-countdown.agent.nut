local SHOW_TEST_EVENTS = false; 

local AGENTRELOADED = true;

const UPDATEINTERVAL = 600; // fetch forecast every 10 minutes
updatehandle <- null;
WEBPAGE <- null;

// Log the URLs to turn LED on/off when agent starts
server.log("Start the countdown by browsing to " + http.agenturl() + "?count=N&mmi=N&type=0");

// HTTP Request handlers expect two parameters:
// request: the incoming request
// response: the response we send back to whoever made the request
function requestHandler(request, response) {
// Check if the variable 'count' was passed into the query
if ("count" in request.query) {
// if it was, send the value of it to the device
    local seconds = request.query.count.tointeger();
    local MMI = request.query.mmi.tointeger();
    local type = request.query.type.tointeger(); // -1 = event cancel, 0 = event, 1 = test event
    local data = [seconds, MMI, type];
    if (type != 1 || SHOW_TEST_EVENTS == true) {
        device.send("count", data);
        response.send(200, "OK - I got a count request");
    }
} 
if ("status" in request.query) {
    connectedString <- "disconnected";
    if (device.isconnected()) {
        connectedString = "connected";
        response.send (200, "The device is " + connectedString);
    } else {
        response.send (500, "The device is " + connectedString);
    }
 
    
} else {
// send a response back to whoever made the request
  response.send(200, "OK - I think I did something");
}
}
 
// your agent code should only ever have ONE http.onrequest call.
http.onrequest(requestHandler);
