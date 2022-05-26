var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');
var Database = require('../lib/database');

// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false })

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
    console.log('Time: ', Date());
    next();
})

// Verifying list of DB
async function listDatabases(client) {
    databasesList = await client.db().admin().listDatabases();

    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
}


// create a new collection named HighscoresCollection

async function createCollection(client, newCollection){
    const result = await client.db("pacman").collection("highscores").insertOne(newListing);
    console.log(`New listing created with the following id: ${result.insertedId}`);
}


router.get('/list', urlencodedParser, function(req, res, next) {
    console.log('[GET /highscores/list]');
    Database.getDb(req.app, function(err, db) {
        if (err) {
            return next(err);
        }

        // Retrieve the top 10 high scores
        var col = db.collection('highscore');
        col.find({}).sort([['score', -1]]).limit(10).toArray(function(err, docs) {
            var result = [];
            if (err) {
                console.log(err);
            }

            docs.forEach(function(item, index, array) {
                result.push({ name: item['name'], cloud: item['cloud'],
                              zone: item['zone'], host: item['host'],
                              score: item['score'] });
            });

            res.json(result);
        });
    });
});


// Accessed at /highscores
router.post('/', urlencodedParser, function(req, res, next) {
    console.log('[POST /highscores] body =', req.body,
                ' host =', req.headers.host,
                ' user-agent =', req.headers['user-agent'],
                ' referer =', req.headers.referer);

    var userScore = parseInt(req.body.score, 10),
        userLevel = parseInt(req.body.level, 10);

    Database.getDb(req.app, function(err, db) {
        if (err) {
            return next(err);
        }

        // Insert high score with extra user data
        const insertHighScore = await highscore.insertOne({
                name: req.body.name,
                cloud: req.body.cloud,
                zone: req.body.zone,
                host: req.body.host,
                score: userScore,
                level: userLevel,
                date: Date(),
                referer: req.headers.referer,
                user_agent: req.headers['user-agent'],
                hostname: req.hostname,
                ip_addr: req.ip
            },
            console.log(`New collection item recorded with the following id: ${insertHighScore.insertedId}`);
             {
                w: 'majority',
                j: true,
                wtimeout: 10000
            }, function(err, result) {
                var returnStatus = '';

                if (err) {
                    console.log(err);
                    returnStatus = 'error';
                } else {
                    console.log('Successfully inserted highscore');
                    returnStatus = 'success';
                }

                res.json({
                    name: req.body.name,
                    zone: req.body.zone,
                    score: userScore,
                    level: userLevel,
                    rs: returnStatus
                });
            });
    });
});

module.exports = router;
