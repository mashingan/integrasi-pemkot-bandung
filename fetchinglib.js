var crypto = require('crypto');
var http = require('http');
var https = require('https');

var keys = {'7na9aj3awo': 'ib57tkh5rdjk4mj'};
var reqid = '7na9aj3awo';

function objectifyArgs(arr) {
  var count = -1;
  var result = {};
  arr.forEach(function (el) {
    count++;
    if (count >= 2) {
      var elm = el.split("=");
      result[elm[0]] = encodeURI(elm[1] || '');
    }
  });
  return result;
}

function toSHA1(data) {
  var generator = crypto.createHash("sha1");
  generator.update(data);
  return generator.digest('hex');
}

function getReq(options, callback) {
  console.log(options.path);
  var prot = options.port === 443? https : http;
  var requesting = prot.request(options, function(response) {
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

function getSum(now) {
  var tokey = keys[reqid] + now;
  console.log(tokey);
  return toSHA1(tokey);
}

module.exports = {
  objectifyArgs: objectifyArgs,
  toSHA1: toSHA1,
  reqid: reqid,
  getReq: getReq,
  getSum: getSum
};
