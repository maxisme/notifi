<?php
//error_reporting(E_ALL);
//ini_set("display_errors", 1);
require "/var/www/notifi.it/socket/db.php";

$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$encryption_key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));

function generateKey($length) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

$credentials = trim($_GET['credentials']);
$key = generateKey(100);
if(strlen($credentials) != 25){
	die();
}

if(isBruteForce($db_user, $db_pass, $encryption_key, $credentials, 1)){
	die("\nToo many requests!");
}

// check if user is already in database
$con = connect();

//limit ammount of requests per ip
$result_user = mysqli_query($con, "SELECT id
FROM `users`
WHERE `credentials` = AES_ENCRYPT('$credentials', '$encryption_key')
"); 

if(mysqli_num_rows($result_user) > 0){
	die("0");
}

// add to user database
$mysqli = new mysqli("localhost", "$db_user", "$db_pass", 'notifi');
if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') '. $mysqli->connect_error);
}

$stmt = $mysqli->prepare("INSERT INTO `users` (`credentials`, `key`) VALUES (
AES_ENCRYPT(?,'$encryption_key'), 
AES_ENCRYPT(?,'$encryption_key')
);");

$stmt->bind_param('ss', $credentials, $key);
if($stmt->execute()){
	echo $key;
}
$stmt->close();
$mysqli->close();

?>