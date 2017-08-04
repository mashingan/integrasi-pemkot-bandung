<?php
/*
function errormsg($kode, $pesan) {
  $result = array("status"=>0, "code"=>$kode, "message"=>$pesan,"data"=>"");
  echo json_encode($result, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
    JSON_PARTIAL_OUTPUT_ON_ERROR);
}
 */

$nik = 3273150911930002;

if (!is_numeric($nik)) {
  echo "Salah NIK nomor, masukkan NIK yang benar";
} else {
  $url1 = "http://localhost:82/disdukcapil/warga?nik=" . $nik;
  $toapi = curl_init();

  curl_setopt($toapi, CURLOPT_HTTPGET, true);
  curl_setopt($toapi, CURLOPT_URL, $url1);
  curl_setopt($toapi, CURLOPT_RETURNTRANSFER, 1);
  //curl_setopt($toapi, CURLOPT_FOLLOWLOCATION, true);
  //curl_setopt($toapi, CURLOPT_SSL_VERIFYPEER, false);

  $content = curl_exec($toapi);
  $errno = curl_errno($toapi);
  $errmsg= curl_strerror($errno);                     

  if ($errno != 0) {
    errormsg($errno, $errmsg);
  } else {
    $jsonresult = json_decode($content, true);
    if ($jsonresult == null) {
      /*
      errormsg(-1, "Server error, invalid JSON");
       */
      $result = array("status"=>0,"code"=>-1,
        "message"=>"Server error, invalid JSON");
      echo json_encode($result, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
        JSON_PARTIAL_OUTPUT_ON_ERROR);
    }
    else {
      //echo "kodeStatus " . $jsonresult["konten"]["kodeStatus"];
      if ($jsonresult["kodeStatus"] != 200) {
        //errormsg($content["konten"]["kodeStatus"], "Ada error");
        $result = array("status"=>0,
          "code"=>$jsonresult["kodeStatus"],
          "message"=>"Ada error");
        echo json_encode($result, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT |
          JSON_PARTIAL_OUTPUT_ON_ERROR);
      } else {
        $konten = $jsonresult["konten"][0];
        //"1993-11-09"
        $year = date("Y") - date_parse_from_format("Y-m-d",
          $konten["tanggalLahir"])["year"];
        // nik, jk, alamat, ttl, usia
        $toreturn = array(
          "nik" => $nik,
          "jenis_kelamin" => $konten["namaJenisKelamin"],
          "alamat" => $konten["alamatLengkap"],
          "tempat_tanggal_lahir" => $konten["tempatLahir"] . " " .
            $konten["tanggalLahir"],
          "usia" => $year
        );
        echo json_encode($toreturn);
        //echo json_encode('{"message":"ok"}');
      }
    }
  }
}
