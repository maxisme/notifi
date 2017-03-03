<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require "functions.php";

$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
$char_limit = 20000;
$con = connect();

//post data
$credentials = trim(clean(mysqli_real_escape_string($con,$_POST['credentials'])));
$title = trim(mysqli_real_escape_string($con,$_POST['title']));
if (isset($_POST["message"]))
	$message = trim(mysqli_real_escape_string($con,$_POST['message']));
if (isset($_POST["img"]))
	$imageURL = trim(mysqli_real_escape_string($con,$_POST['img']));
if (isset($_POST["link"]))
	$link = trim(mysqli_real_escape_string($con,$_POST['link']));

//validation
if(empty($credentials) || strlen($credentials) != 25){
	die("invalid credentials\n");
} 

if(empty($title)){
	die("No title\n"); 
}else if(strlen($title) > $char_limit){
	die("Title too long! Must be less than $char_limit charachters\n");
}

if(empty($message)){
	$message = " "; 
}else if(strlen($message) > $char_limit){
	die("Message too long! Must be less than $char_limit charachters\n");
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

if(isBruteForce($credentials)){
	die("Too many requests! Please wait a minute.\n");
}

//check if user exists
if(!userExists(myHash($credentials))){
	die();
}


$insert_notification_query = mysqli_query($con, "INSERT INTO notifications (credentials, title, message, image, link) VALUES (
	'".myHash($credentials)."', 
	AES_ENCRYPT('$title','$key'),
	AES_ENCRYPT('$message','$key'),
	AES_ENCRYPT('$imageURL','$key'),
	AES_ENCRYPT('$link','$key')
)");

if($insert_notification_query){
	// send message to ratchet to send message to user
	$context = new ZMQContext();
	$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
	$socket->connect("tcp://localhost:5555");
	$socket->send(myHash($credentials));
}else{
	echo "Error inserting notification into database!\nPlease send this to max@m4x.co:\n\n";
}
?>