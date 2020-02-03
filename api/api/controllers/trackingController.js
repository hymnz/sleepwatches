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
  
  if (new_track.payload.sleep.InBed != null) {
    var i=0
    console.log(new_track.payload.sleep.InBed);
    for (let item of new_track.payload.sleep.InBed) {
      new_track.payload.sleep.InBed[i].start = decrypt(item.start);
      new_track.payload.sleep.InBed[i].end = decrypt(item.end);
      i++;
    }
  }

  if (new_track.payload.sleep.Asleep != null) {
    var i=0
    console.log(new_track.payload.sleep.Asleep);
    for (let item of new_track.payload.sleep.Asleep) {
      new_track.payload.sleep.Asleep[i].start = decrypt(item.start);
      new_track.payload.sleep.Asleep[i].end = decrypt(item.end);
      i++;
    }
  }

  if (new_track.payload.sleep.Awake != null) {
    var i=0
    for (let item of new_track.payload.sleep.Awake) {
      console.log(new_track.payload.sleep.Awake);
      new_track.payload.sleep.Awake[i].start = decrypt(item.start);
      new_track.payload.sleep.Awake[i].end = decrypt(item.end);
      i++;
    }
  }
  console.log(new_track);

  new_track.save(function(err, track) {
    if (err)
      res.send(err);
    res.json(track);
  });
};

exports.test = function(req, res) {
  res.send({ 'result': 'success' });
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
