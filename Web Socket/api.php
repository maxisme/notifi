<?php
$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
$db_user = file_get_contents(dirname(__DIR__)."/db.user");
$key = file_get_contents(dirname(__DIR__)."/encryption.key");

function clean($string) {
   $string = str_replace(' ', '', $string); // removes all spaces
   return preg_replace('/[^A-Za-z0-9\-]/', '', $string);
}

//post data
$credentials = trim(clean($_POST['credentials']));
$title = trim(clean($_POST['title']));
$message = trim(clean($_POST['message']));
$imageURL = trim(clean($_POST['img']));
$link = trim(clean($_POST['link']));

//other variables
$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
$ip_limit = 10;
$cred_limit = 10;
$ip_to_cred_limit = 6;


if(empty($credentials) || strlen($credentials) != 25){
	die("invalid credentials");
}

if(empty($title)){
	die("No title"); 
}

if(empty($message)){
	$message = " "; 
}

if(empty($imageURL)){
	$imageURL = " "; 
}

if(empty($link)){
	$link = " "; 
}else if (filter_var($link, FILTER_VALIDATE_URL) === FALSE) {
    die('Not a valid URL');
}


$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
if (!$con) {
	die("error connecting to database");
} 

//limit ammount of requests per ip
$limit_ip_query = mysqli_query($con, "SELECT id
FROM `notifications`
WHERE ip = AES_ENCRYPT('$ip', '$key')
AND time >= date_sub(now(), interval 1 minute)
"); 
	
if(mysqli_num_rows($limit_ip_query) >= 10){
	die("You have hit Limit 1. Please wait 1 minute.");
}

//limit ammount of requests per credential
$limit_cred_query = mysqli_query($con, "SELECT id
FROM `notifications`
WHERE credentials = AES_ENCRYPT('$credentials', '$key')
AND time >= date_sub(now(), interval 1 minute)
");
	
if(mysqli_num_rows($limit_spec_query) >= 10){
	die("You have hit Limit 2. Please wait 1 minute.");
}

//limit ammount of requests per ip to credential 
$limit_spec_query = mysqli_query($con, "SELECT id
FROM `notifications`
WHERE credentials = AES_ENCRYPT('$credentials', '$key')
AND ip = AES_ENCRYPT('$ip', '$key')
AND time >= date_sub(now(), interval 1 minute)
");
	
if(mysqli_num_rows($limit_spec_query) >= 6){
	die("You have hit Limit 3. Please wait 1 minute.");
}

$mysqli = new mysqli("localhost", "notify", "$db_pass", "$db_user");

if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') '
           . $mysqli->connect_error);
}

$stmt = $mysqli->prepare("INSERT INTO notifications (credentials, title, message, image, link, ip) VALUES (
AES_ENCRYPT(?,'$key'), 
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key')
)");

$stmt->bind_param('ssssss', $credentials, $title, $message, $imageURL, $link, $ip);

$stmt->execute();

$stmt->close();
$mysqli->close();

// send message to ratchet to send message to user
$context = new ZMQContext();
$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
$socket->connect("tcp://localhost:5555");
$socket->send($credentials);
?>
