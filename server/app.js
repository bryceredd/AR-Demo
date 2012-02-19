var express = require('express')
var mongodb = require('mongodb'),
    Db = mongodb.Db,
    Server = mongodb.Server


exports.createServer = function() {
    app = express.createServer()
    
    app.configure(function() {
        app.use(express.bodyParser())
    })

    var client = new Db('players', new Server("127.0.0.1", 27017, {}))
    
    app.get('/players', function(req, res) {
        client.open(function(err, obj) {
            client.collection("players", function(err, collection) {
                collection.find({}, function(err, cursor) {
                    cursor.toArray(function(err, items) {
                        res.send(items)
                    })
                })
            })
        })
    })

    app.post('/update', function(req, res) {
        client.open(function(err, obj) {
            client.collection("players", function(err, collection) { 
                collection.update({playerId: req.body.playerId}, req.body, {upsert:true, safe:true}, function(err, doc) {
                    res.send()
                })
            })
        })
    })

    app.get('/clean', function(req, res) {
        client.open(function(err, obj) {
            client.collection("players", function(err, collection) {
                collection.remove(function(err, doc) {
                    res.send()
                })
            })
        })
    })

    app.get("/", function(req, res) {
        res.send("alive")
    })

    return app
}

exports.createServer().listen(80);

