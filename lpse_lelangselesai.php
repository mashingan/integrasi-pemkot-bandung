<?php
$url1 = "https://inaproc.lkpp.go.id/isb/api/47f2eedb-26c1-46bf-b94f-0ce65c892d34/json/13638831/LelangSelesaiSPSELPSE/tipe/4:4:4/parameter/"
  .$tahun .":" .$bulan .":" .$kode_lpse;
$toapi = curl_init();

curl_setopt($toapi, CURLOPT_HTTPGET, true);
curl_setopt($toapi, CURLOPT_URL, $url1);
curl_setopt($toapi, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($toapi, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($toapi, CURLOPT_SSL_VERIFYPEER, false);

$content = curl_exec($toapi);
$errno = curl_errno($toapi);
$errmsg= curl_strerror($errno);                     

if ($errno != 0) {
  $result=array('status'=>0,'code'=>$errno,'message'=>$errmsg,'data'=>'');
  echo json_encode($result,JSON_PRETTY_PRINT | JSON_FORCE_OBJECT | JSON_PARTIAL_OUTPUT_ON_ERROR);
}
else {
  echo $content;
}
