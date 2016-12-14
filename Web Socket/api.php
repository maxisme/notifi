<?php
$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
$db_user = file_get_contents(dirname(__DIR__)."/db.user");
$key = file_get_contents(dirname(__DIR__)."/encryption.key");

//post data
$credentials = $_POST['credentials'];
$title = $_POST['title'];
$message = $_POST['message'];
$imageURL = $_POST['img'];
$link = $_POST['link'];

if(empty($credentials)){
	die("No credentials");
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
}

$mysqli = new mysqli("localhost", "notify", "$db_pass", "$db_user");

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

$stmt->execute();

$stmt->close();
$mysqli->close();

// send message to ratchet to send message to user
$context = new ZMQContext();
$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
$socket->connect("tcp://localhost:5555");
$socket->send($credentials);
?>