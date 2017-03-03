<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);
require "functions.php";

$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$encryption_key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));

$con = connect();

$credentials = trim(mysqli_real_escape_string($con,$_GET['credentials']));
$key = randomString(100);
if(strlen($credentials) != 25){
	die();
}

if(isBruteForce($credentials, 2)){
	die("\nToo many requests from IP address try again in 1 minute!");
}

$con = connect();

// check if user is already in database
$result_user = mysqli_query($con, "SELECT id
FROM `users`
WHERE `credentials` = '".myHash($credentials)."'
"); 

if(mysqli_num_rows($result_user) > 0){
	die("0");
}

$insert_key = mysqli_query($con, "INSERT INTO `users` (`credentials`, `key`) VALUES (
'".myHash($credentials)."', '".myHash($key)."'
);");

if($insert_key){
	echo $key; //return key
}

?>