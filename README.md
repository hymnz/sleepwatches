# Instructions

## Apple Watch Config


### file Constant.swift
```
KEY256 -> key ที่ใช้ในการ encrypt
IV -> iv ที่ใช้ในการ encrypt
HOST -> Host ของ API ที่ต้องการเก็บข้อมูล
TIME_INTERVAL -> เวลาในการส่งข้อมูลไปเก็บที่ Server
```

### Build app to testflight
```
บน Mac
    1. add certificates เพื่อ build app ขึ้น tesflight
    เปิด file Certificates.p12
    password s133pW@tch3s
    
    2.
https://codewithchris.com/submit-your-app-to-the-app-store/
ทำตาม Chapter 5
```

## API Config


### file trackingController.js

```
const key -> key ที่ใช้ในการ decrypt
const iv -> iv ที่ใช้ในการ encrypt
```

### run Docker api
```
ที่ path ../api
docker-compost up
```
