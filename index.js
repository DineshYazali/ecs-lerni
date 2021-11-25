const express = require('express');
const app = express();
// Run the app by serving the static files
// in the dist directory
app.use(express.static(__dirname + '/angular'));

console.log(__dirname);
// Start the app by listening on the default
// Heroku port
app.listen(4200, function() {
    console.log(" server running");
});
