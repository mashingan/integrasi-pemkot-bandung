<?php
$tahun = (int) $tahun;
if ($tahun < 2013 || $tahun > 2016) {
  $result=array('status'=>0,'code'=>$errno,
    'message'=>"hanya ada pada tahun 2013-2016",'data'=>'');
  echo json_encode($result,JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
    JSON_PARTIAL_OUTPUT_ON_ERROR);
}

$url1 = "http://data.bandung.go.id/service/index.php/lpse/".$berdasarkan
  ."?tahun=".$tahun;
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
