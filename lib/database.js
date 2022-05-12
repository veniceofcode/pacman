'use strict';

//var MongoClient = require('mongodb').MongoClient;
const { MongoClient } = require('mongodb')
var serviceBindings = require('kube-service-bindings');
var config = require('./config');
var _db;

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

async function listDatabases(client) {
    databasesList = await client.db().admin().listDatabases();

    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));
};

async function Database() {
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

    // Connect to the MongoDB cluster
    await client.connect();
    console.log('xxxConnected successfully to server');
    
    //list all the databases
    await listDatabases(client);

}

module.exports = exports = new Database(); // Singleton
