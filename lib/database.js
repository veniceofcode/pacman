'use strict';

//var MongoClient = require('mongodb').MongoClient;
const { MongoClient } = require('mongodb')
var serviceBindings = require('kube-service-bindings');
var config = require('./config');
var _db;

function Database() {
    this.connect = function(app, callback) {
    /**
     * Connection URI. Update <username>, <password>, and <your-cluster-url> to reflect your cluster.
     * See https://docs.mongodb.com/drivers/node/ for more details
     */
    let bindings;
try {
    // check if the deployment has been bound to a pg instance through
    // service bindings. If so use that connect info
    bindings = serviceBindings.getBinding('MONGODB', 'mongodb');
} catch (err) { // proper error handling here
    console.log(err);
};    
    const url = bindings.url + '/pacman?retryWrites=true&w=majority';
        //const url = 'mongodb+srv://atlas-db-user-1652301187443685327:%?n9G?2J@cluster0.gy65h.mongodb.net/pacman';
        console.log('check url');
        console.log(url);
        console.log(bindings.connectionOptions);
        const client = new MongoClient(url, bindings.connectionOptions);

//    try {

    // Connect to the MongoDB cluster
    client.connect();
    console.log('xxxConnected successfully to server');


            MongoClient.connect(url,
                                bindings.connectionOptions,
                                function (err, db) {
                                    if (err) {
                                        console.log(err);
                                        console.log(url);
                                        console.log(bindings.connectionOptions);
                                    } else {
                                        _db = db;
                                        app.locals.db = db;
                                    }
                                    callback(err);
                                });
    }

    this.getDb = function(app, callback) {
        if (!_db) {
            this.connect(app, function(err) {
                if (err) {
                    console.log('Failed to connect to database server');
                } else {
                    console.log('Connected to database server successfully');
                }

                callback(err, _db);
            });
        } else {
            callback(null, _db);
        }

    }
}

module.exports = exports = new Database(); // Singleton
