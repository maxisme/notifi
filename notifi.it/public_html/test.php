<?php

include "/var/www/notifi.it/public_html/functions.php";

$string = randomString(100);
if(decrypt(encrypt($string)) == $string){
    echo "<h1>succcess</h1>";
}

echo myHash("SCqJj4PDPwJtUbn9qyAV6ftFv");