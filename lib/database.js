'use strict';

var MongoClient = require('mongodb').MongoClient;
var serviceBindings = require('kube-service-bindings');
var config = require('./config');
var _db;

let bindings;
try {
    // check if the deployment has been bound to a pg instance through
    // service bindings. If so use that connect info
    bindings = serviceBindings.getBinding('MONGODB', 'mongodb');
} catch (err) { // proper error handling here
};

function Database() {
    this.connect = function(app, callback) {
    /**
     * Connection URI. Update <username>, <password>, and <your-cluster-url> to reflect your cluster.
     * See https://docs.mongodb.com/drivers/node/ for more details
     */
    const url = bindings.url + '?retryWrites=true&w=majority';

            MongoClient.connect(url,
                                bindings.connectionOptions,
                                function (err, db) {
                                    if (err) {
                                        console.log(err);
                                        console.log(config.database.url);
                                        console.log(config.database.options);
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
