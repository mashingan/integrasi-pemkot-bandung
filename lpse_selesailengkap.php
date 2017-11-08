<?php
$url1 = "https://inaproc.lkpp.go.id/isb/api/ed238dd0-de66-4456-bbc5-157ade8e7968/json/13617012/LelangSelesaiLengkap/tipe/4:4/parameter/"
  .$tahun .":" .$bulan;
$toapi = curl_init();

curl_setopt($toapi, CURLOPT_HTTPGET, true);
curl_setopt($toapi, CURLOPT_URL, $url1);
curl_setopt($toapi, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($toapi, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($toapi, CURLOPT_SSL_VERIFYPEER, false);

$content = curl_exec($toapi);
$errno = curl_errno($toapi);
$errmsg= curl_strerror($errno);                     
$reslen = curl_getinfo($toapi, CURLINFO_CONTENT_LENGTH_DOWNLOAD);

echo $content;

/*
if ($errno != 0) {
  $result=array('status'=>0,'code'=>$errno,'message'=>$errmsg,'data'=>'');
  echo json_encode($result,JSON_PRETTY_PRINT | JSON_FORCE_OBJECT | JSON_PARTIAL_OUTPUT_ON_ERROR);
}
else if ($reslen["size_download"] == 1) {
  $result=array('status'=>0,'code'=>$errno,'message'=>'Zero length data'
    ,'data'=>'');
  echo json_encode($result,JSON_PRETTY_PRINT | JSON_FORCE_OBJECT | JSON_PARTIAL_OUTPUT_ON_ERROR);
}
else {
  echo $content;
}
 */
curl_close($toapi);
