'use strict';
var mongoose = require('mongoose');
var timestamps = require('mongoose-timestamp');
var Schema = mongoose.Schema;

var DailyTrackSchema = new Schema({
  userId: { type: String },
  payload: {
    acc: {
      x: { type: Number },
      y: { type: Number },
      z: { type: Number } 
    },
    gyr: {
      x: { type: Number },
      y: { type: Number },
      z: { type: Number } 
    },
    geo: {
      lat: { type: String },
      long: { type: String },
    },
    hr: {type: Number},
    speed: { type: Number },
    altitude: { type: Number }
  },
  ts: {
    type: Number
  }
});

var SleepTrackSchema = new Schema({
  userId: { 
    type: String 
  },
  payload: {
    sleep: {
      InBed: [{
        _id: false,
        start: {type: String},
        end: {type: String}
      }],
      Asleep: [{
        _id: false,
        start: {type: String},
        end: {type: String}
      }],
      Awake: [{
        _id: false,
        start: {type: String},
        end: {type: String}
      }]
    },
    summary: {
      totalInBed: {type: Number},
      totalAsleep: { type: Number },
      totalAwake: { type: Number }
    },
  }
});

DailyTrackSchema.plugin(timestamps);
SleepTrackSchema.plugin(timestamps);

module.exports = mongoose.model('DailyTrack', DailyTrackSchema, 'apple_sensors');
module.exports = mongoose.model('SleepTrack', SleepTrackSchema, 'apple_sleeps');