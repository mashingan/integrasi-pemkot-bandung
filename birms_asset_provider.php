<?php
$url1 = "https://birms.bandung.go.id/api/asset/";
$toapi = curl_init();

$dinas = str_ireplace('-', '%20', $dinas);
$dinas = str_ireplace('_', '%20', $dinas);
$url1 = $url1 . $tahun . ":" . $dinas;

curl_setopt($toapi, CURLOPT_HTTPGET, true);
curl_setopt($toapi, CURLOPT_URL, $url1);

$content = curl_exec($toapi);
$errno = curl_errno($toapi);
$errmsg= curl_strerror($errno);                     

if ($errno != 0) {
  $result=array('status'=>0,'code'=>$errno,'message'=>$errmsg,'data'=>'');
  echo json_encode($result,JSON_PRETTY_PRINT | JSON_FORCE_OBJECT | JSON_PARTIAL_OUTPUT_ON_ERROR);

;
}
else {
  echo $content;
}
