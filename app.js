var express = require('express');
var http = require('http');
var greenlock = require('greenlock-express');
var app = express();

var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9" +
	"kYXBvZGlrLmRpc2Rpa2tvdGEuYmFuZHVuZy5nby5pZCIsImlhdCI6MTQ5MTgyMjE3N" +
	"CwiZXhwIjoxODA3MTgyMTc0LCJ1c2VybmFtZSI6ImRpc2tvbWluZm9iZGcifQ." +
	"VQAntH-Hb_VOPbEjVtFThG50Mcnfgbm71CRZAXOqLKA";

function getReq(options, callback) {
  console.log(options.path);
  var requesting = http.request(options, function(response) {
    var output = "";
    response.setEncoding("utf8");
    response.on("data", function (chunk) {
      output += chunk;
    });
    response.on("end", function () {
      callback(output);
    });
  });
  requesting.end();
}

function dapodikOption(pathurl, apipath) {
  apipath = apipath || "sekolah";
  return {
    port: 80,
    host: 'dapodik.disdikkota.bandung.go.id',
    method: 'GET',
    path: "/api-dapodik/"+ apipath +"?token=" + token + pathurl
  };
}
  
/*
app.get('/dapodik/list_sekolah', function (req, res) {
  getReq(dapodikOption("&fields=npsn,nama"), function (out) {
    res.send(out);
  });
});
*/

app.get('/echo-header', function (req, res) {
  console.log("headers:", req.headers);
  for (var key in req.headers) {
    res.append(key, req.headers[key]);
  }
  res.append('echo-header', 'is ok');
  res.json(req.headers);
  res.end();
});

app.get('/dapodik/sekolah', function (req, res) {
  var pathurl;
  console.log(req.query.npsn);
  if (!req.query.npsn) {
    getReq(dapodikOption("&fields=npsn,nama"), function (out) {
      res.send(out);
    });
    return;
  }

  var options = dapodikOption("&filter[npsn]=" + req.query.npsn);

  getReq(options, function (output) {
    //console.log(output);
    output = JSON.parse(output);
    var data = output.data;
    console.log(data);
    /*
      Output yang dibutuhkan adalah:
      nama, npsn, nama_kepala_sekolah, nip_kepala_sekolah,
      alamat, kecamatan, kelurahan, kota, provinsi, jumlah siswa laki,
      jumlah siswa perempuan, longitude, latitude
    */
    var result = {
      nama: data[0].attributes.nama,
      npsn: data[0].attributes.npsn,
      alamat: data[0].attributes.alamat_jalan,
      kelurahan: data[0].attributes.desa_kelurahan,
      lintang: data[0].attributes.lintang,
      bujur: data[0].attributes.bujur
    };
    console.log(result);
    var kecamatan_id = data[0].attributes.kecamatan_id;
    getReq(dapodikOption("&filter[id]=" + kecamatan_id, "kecamatan"),
      function (kecdata) {
        //var attr = JSON.parse(kecdata)[0].attributes;
        var attr;
        try {
          attr = JSON.parse(kecdata).data[0].attributes;
        } catch (e) {
          console.log(kecdata + ": not found");
        }
        result.kecamatan = attr.nama;
        /*
          Yang kurang adalah:
          - nama_kepala_sekolah
          - nip_kepala_sekolah
          - kota
          - provinsi
          - jumlah siswa laki
          - jumlah siswa perempuan
        */
        console.log("Hasil final: " + result);
        res.json(result);
    });
    
    //res.send(output);
  });
});

var server = greenlock.create({
  // change to https://acme-v01.api.letsencrypt.org/directory
  // after testing the setup works
  //server: "https://acme-v01.api.letsencrypt.org/directory",
  server: "staging",
  email: "rahmat.d.ruffy@gmail.com",
  agreeTos: true,
  approveDomains: ["mantra.bandung.go.id"],
  app: app
});

//server.listen(443, 3000);

app.listen(3000, function () {
  console.log("Example app listening on port 3000");
});
