'use strict';
module.exports = function(app) {
  var trackController = require('../controllers/trackingController');

  app.route('/api/v1/apple/watches').post(trackController.daily);

  app.route('/api/v1/apple/sleep').post(trackController.sleep);

  app.route('/test').get(trackController.test);

};