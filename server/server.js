var express = require('express')

app = express.createServer()
app.use(express.bodyParser());

var players = new Array();
players[0] = {"id": 1, "name": "Guy Harding", "location": { "lat": 123456, "lon": 1234532 }, "avatar": 1 };
players[1] = {"id": 2, "name": "Bryce Redd", "location": { "lat": 123456, "lon": 1234532 }, "avatar": 2 };
players[2] = {"id": 3, "name": "Seth Jenks", "location": { "lat": 123456, "lon": 1234532 }, "avatar": 3 };
players[3] = {"id": 4, "name": "Adam Jacox", "location": { "lat": 123456, "lon": 1234532 }, "avatar": 4 };
players[4] = {"id": 5, "name": "John Weeks", "location": { "lat": 123456, "lon": 1234532 }, "avatar": 5 };

app.get('/',  function(req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Unicorns rock!\n');
})

app.all('/player/:id/:op?', function(req, res, next){
  req.player = players[req.params.id];
  if (!req.player) {
      // add user
      console.log("Adding new user to app");
      players.push({"id": players.length + 1, "location": { "lat": req.body.lat, "lon": req.body.lon} });
      req.player = players[req.params.id];
  }
  next();
});

app.post('/player/:id/location', function(req, res) {
    // get the parameters
    console.log('updating ' + req.player.name + ' location from ' + req.player.location.lat + ' ' + req.player.location.lon + ' to ' + req.body.lat + ' ' + req.body.lon);

    // console.log(players);
    // store in dictionary
    if (req.body && req.body.lat && req.body.lon) {
	req.player.location.lat = req.body.lat;
	req.player.location.lon = req.body.lon;

	// console.log(players.toString());
	// return all players id's and locations
	res.send(players)
    } else {
	// return status code 400 - Bad request
	res.writeHead(400, {'Content-Type': 'text/plain'});
	res.end('Bad request\n');
    }
})

app.get('/player/:id', function(req, res) {
    // get the player id 

    // if no id, return every player & profile
    
    // return the player profile (including avatar)

    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Return player profile\n');
})

app.get('/player/:id/avatar', function(req, res) {
    // get the player id 

    // if no id, return every player
    
    // get the player profile (including avatar)

    // return all other players id's and locations
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Unicorns rock!\n');
})

app.listen(1337)