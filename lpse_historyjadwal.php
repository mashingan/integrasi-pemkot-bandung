<?php
$url1 = "https://inaproc.lkpp.go.id/isb/api/5f19aa67-a5b4-4d80-86f6-5f4175cd45bb/json/13638841/historyjadwal/tipe/4:4/parameter/"
  .$kode_lelang .":" .$kode_lpse;
$toapi = curl_init();

curl_setopt($toapi, CURLOPT_HTTPGET, true);
curl_setopt($toapi, CURLOPT_URL, $url1);

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
