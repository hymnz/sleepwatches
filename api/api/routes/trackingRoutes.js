'use strict';
module.exports = function(app) {
  var trackController = require('../controllers/trackingController');

  app.route('/daily/track').post(trackController.daily);

  app.route('/sleep/track').post(trackController.sleep);

    app.route('/test')
    .get(trackController.test);

};