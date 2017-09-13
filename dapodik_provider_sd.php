<?php
$result=dbExecute(
  $dbdriver='postgres',
  $hostname='103.24.150.111',
  $username='postgres',
  $password='mantraconf2016',
  $dbname='cache_dapodik',
  $sql='SELECT nama, alamat, jumlah_siswa_laki_laki, jumlah_siswa_perempuan FROM sekolah where jenjang_id=4',
  //$bindfield=array('table'=>$table),
  $trx=false
);

var_dump($result);

if ($result != null) {
  $output = array();
  foreach($result->getRows() as $sekolah) {
    $item = array(
      "nama" => $sekolah["nama"],
      "alamat" => $sekolah["alamat"]);
    $jumlahSiswa = $sekolah["jumlah_siswa_laki_laki"] +
      $sekolah["jumlah_siswa_perempuan"];
    $item["jumlah_siswa"] = $jumlahSiswa;
    //array_push($output, $item);
    $output[] = $item;
  }
  echo json_encode($output, JSON_PRETTY_PRINT |
    JSON_PARTIAL_OUTPUT_ON_ERROR);

} else {
  $result = array("status"=>0,"code"=>-1,
    "message"=>"Server error, invalid JSON");
  echo json_encode($result, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
    JSON_PARTIAL_OUTPUT_ON_ERROR);
}
