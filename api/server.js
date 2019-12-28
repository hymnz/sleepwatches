var express = require('express'),
  fs = require('fs') ,
  https = require("https");
  app = express(),
  port = process.env.PORT || 443,
  keys_dir = './keys/' ,
  server_options = { 
    key  : fs.readFileSync(keys_dir + 'server.key'),
    cert : fs.readFileSync(keys_dir + 'server.cert') 
  },
  mongoose = require('mongoose'),
  DailyTrack = require('./api/models/trackingModel'),
  SleepTrack = require('./api/models/trackingModel'),
  bodyParser = require('body-parser');
  
// mongoose instance connection url connection
mongoose.Promise = global.Promise;
mongoose.connect('mongodb://mongo:27017/track'); 


app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());


var routes = require('./api/routes/trackingRoutes');
routes(app);


https.createServer(server_options,app).listen(port)   
// app.listen(port);

console.log('test api on port xxx: ' + port);