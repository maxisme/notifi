<?php
//error_reporting(E_ALL);
//ini_set("display_errors", 1);
$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));

require "/var/www/notifi.it/socket/db.php";

//post data
$credentials = trim(clean($_POST['credentials']));
$title = trim($_POST['title']);
$message = trim($_POST['message']);
$imageURL = trim($_POST['img']);
$link = trim($_POST['link']);

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

if(isBruteForce($db_user, $db_pass, $key, $credentials)){
	die("\nToo many requests!");
}

$mysqli = new mysqli("localhost", "$db_user", "$db_pass", 'notifi');

if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') '
            . $mysqli->connect_error);
}

$stmt = $mysqli->prepare("INSERT INTO notifications (credentials, title, message, image, link) VALUES (
AES_ENCRYPT(?,'$key'), 
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key'),
AES_ENCRYPT(?,'$key')
)");

$stmt->bind_param('sssss', $credentials, $title, $message, $imageURL, $link);

if($stmt->execute()){
	// send message to ratchet to send message to user
	$context = new ZMQContext();
	$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
	$socket->connect("tcp://localhost:5555");
	$socket->send($credentials);
	echo "sent";
}else{
	echo "Error inserting notification into database!\nPlease send this to max@m4x.co:\n\n";
	print_r($stmt);
}

$stmt->close();
$mysqli->close();
?>