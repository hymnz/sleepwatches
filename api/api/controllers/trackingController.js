'use strict';

const crypto = require('crypto');
const algorithm = 'aes-256-cbc';
const key = "12345678901234561234567890123456";
const iv = "abcdefghijklmnop";

var mongoose = require('mongoose');
var DailyTrack = mongoose.model('DailyTrack');
var SleepTrack = mongoose.model('SleepTrack');

exports.daily = function(req, res) {
  var new_track = new DailyTrack();
  
  var json = req.body;
  var payload = json.payload;
  
  new_track.userId = json.userId;
  new_track.ts = json.ts;

  new_track.payload.hr = decrypt(payload.hr);
  new_track.payload.speed = decrypt(payload.speed);

  new_track.payload.altitude = decrypt(payload.altitude)

  var geo = payload.geo;
  if (geo != null) {
    new_track.payload.geo.lat = decrypt(geo.lat);
    new_track.payload.geo.long = decrypt(geo.long);
  } 

  var acc = payload.acc;
  if (acc != null) {
    new_track.payload.acc.x = decrypt(acc.x);
    new_track.payload.acc.y = decrypt(acc.y);
    new_track.payload.acc.z = decrypt(acc.z);
  } 

  var gyr = payload.gyr;
  if (gyr != null) {
    new_track.payload.gyr.x = decrypt(gyr.x);
    new_track.payload.gyr.y = decrypt(gyr.y);
    new_track.payload.gyr.z = decrypt(gyr.z);
  } 

  new_track.save(function(err, track) {
    if (err)
      res.send(err);
    res.json(track);
  });
};

exports.sleep = function(req, res) {
  var new_track = new SleepTrack(req.body);
  new_track.type = decrypt(new_track.type);
  new_track.start = decrypt(new_track.start);
  new_track.end = decrypt(new_track.end);
  new_track.save(function(err, track) {
    if (err)
      res.send(err);
    res.json(track);
  });
};

exports.test = function(req, res) {
    res.body("test success")
  };

function decrypt(text) {

  if (text == undefined) {
    return undefined;
  }
  let encryptedText = Buffer.from(text, 'base64');
  let decipher = crypto.createDecipheriv(algorithm, Buffer.from(key), iv);
  let decrypted = decipher.update(encryptedText);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  let string = decrypted.toString();
  if (string == ''){
    return undefined;
  }
  return string;
  }
