<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);
$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));

require "/var/www/notifi.it/public_html/functions.php";

$word_limit = 20000;
//post data
$credentials = filter_str(trim(clean($_POST['credentials'])));
$title = filter_str(trim($_POST['title']));
if (isset($_POST["message"]))
	$message = filter_str(trim($_POST['message']));
if (isset($_POST["img"]))
	$imageURL = filter_str(trim($_POST['img']));
if (isset($_POST["link"]))
	$link = filter_str(trim($_POST['link']));

if(empty($credentials) || strlen($credentials) != 25){
	die("invalid credentials\n");
} 

if(empty($title)){
	die("No title\n"); 
}else if(strlen($title) > $word_limit){
	die("Title too long! Must be less than $word_limit charachters\n"); 
}

if(empty($message)){
	$message = " "; 
}else if(strlen($message) > $word_limit){
	die("Message too long! Must be less than $word_limit charachters\n"); 
}

if(empty($imageURL)){
	$imageURL = " "; 
}else{
	if (!@getimagesize($imageURL)) {
		echo "$imageURL is not a valid image. Sent without!\n";
		$imageURL = " "; 
	} 
} 

if(empty($link)){ 
	$link = " "; 
}else if (filter_var($link, FILTER_VALIDATE_URL) === FALSE) {
    echo "$link is not a valid link. Sent without\n";
	$link = " "; 
}

if(isBruteForce($db_user, $db_pass, $key, $credentials)){
	die("Too many requests! Please wait a minute.\n");
}

//check if user exists
if(!userExists($credentials)){
	die();
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
}else{
	echo "Error inserting notification into database!\nPlease send this to max@m4x.co:\n\n";
	print_r($stmt);
}

$stmt->close();
$mysqli->close();
?>