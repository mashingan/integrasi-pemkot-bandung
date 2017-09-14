<?php

$url = "http://data.bandung.go.id/service/kependudukan.php?type=range_umur";
/*
http://data.bandung.go.id/service/kependudukan.php?type=angkatan_kerja
http://data.bandung.go.id/service/kependudukan.php?type=rekap
 */
$toapi = curl_init();

curl_setopt($toapi, CURLOPT_HTTPGET, true);
curl_setopt($toapi, CURLOPT_URL, $url);
curl_setopt($toapi, CURLOPT_RETURNTRANSFER, 1);
//curl_setopt($toapi, CURLOPT_FOLLOWLOCATION, true);
//curl_setopt($toapi, CURLOPT_SSL_VERIFYPEER, false);

$content = curl_exec($toapi);
$errno = curl_errno($toapi);
$errmsg= curl_strerror($errno);                     

if ($errno != 0) {
  $result = array("status"=>0,"code"=>-1,
    "message"=>"Server error, invalid JSON");
  echo json_encode($result, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
      JSON_PARTIAL_OUTPUT_ON_ERROR);
} else {
  echo $content;
}
