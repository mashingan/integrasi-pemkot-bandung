/*
 * contoh parameter:
 * limit=10
 * page=1
 * fields=peg_nip-jabatan
 * table=pegawai
 * filter=peg_nip
 * order=none
 * ke=2 khusus untuk bulan
 *
 */
/*
 * Contoh cara pakai:
 * node get_erk_test.js ke=2 limit=10 page=1 fields=peg_nip-jabatan \
 *  table=pegawai filter=peg_nip order=none page=1
 *
 */

var lib = require('./fetchinglib');
var qs = require('querystring');
//var mantra = '103.24.150.111:83';

var args = lib.objectifyArgs(process.argv);
var now = Date.now();

console.log(args);

//http://mantra.bandung.go.id/mantra/api/bkpp/erk_aktifitas/lihat_isi/table=master_aktifitas&fields=kode_aktifitas-nama_aktifitas&filter=none&page=1&limit=10&order=none&id=7na9aj3awo&key=895b8df16bb5ffddcc93b2ed2bfbdbe87428211c&time=1496214247434"
var result;
lib.getReq({
  port: 80,
  method: 'GET',
  host: 'mantra.bandung.go.id',
  //path: '/mantra/json/bkpp/erk_aktifitas/lihat_isi/' +
  //path: '/mantra/json/bkpp/erk_bulan/lihat_isi/' +
  //path: '/mantra/json/bkpp/erk_analitik/lihat_isi/' +
  path: '/mantra/json/bkpp/simpeg/lihat_isi/' +
    'time=' + now +
    '&key=' + lib.getSum(now) +
    '&id=' + lib.reqid +
    '&' + qs.stringify(args),
  headers: {
    'user-agent': 'MANTRA',
    //'AccessKey': '3n728l4n6i' // aktifitas
    //'AccessKey': 'myyayw8xk1' // bulan
    //'AccessKey': '9p2rtpe7bp' // analitik
    'AccessKey': 'ycksjuekk8' // simpeg
  }
}, function (hasil) {
  result = hasil;
  console.log(hasil);
});
