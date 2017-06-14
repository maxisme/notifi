<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

if (!@fsockopen('127.0.0.1', 1203)) {
    header('HTTP/1.1 500 Internal Server Error');
    die("Server Down. Please try again later.\n");
}

require "functions.php";

$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
$char_limit = 20000;
$img_limit = 10;
$con = connect();

//post data
$credentials = trim(clean(mysqli_real_escape_string($con,$_POST['credentials'])));
$title = trim(mysqli_real_escape_string($con,$_POST['title']));
if (isset($_POST["message"])) $message = trim(mysqli_real_escape_string($con,$_POST['message']));
if (isset($_POST["image"])) $imageURL = trim(mysqli_real_escape_string($con,$_POST['image']));
if (isset($_POST["link"])) $link = trim(mysqli_real_escape_string($con,$_POST['link']));

//validation

if(isBruteForce($con, $credentials)){
    die("You have made too many requests! Please wait a minute.\n");
}

if(empty($credentials) || strlen($credentials) != 25){
	die("Invalid credentials!\n");
} 

if(empty($title)){
	die("You must enter a title!\n");
}else if(strlen($title) > $char_limit){
	die("Title too long! Must be less than $char_limit characters!\n");
}

if(empty($message)){
	$message = " "; 
}else if(strlen($message) > $char_limit){
	die("Message too long! Must be less than $char_limit characters!\n");
}

if(empty($imageURL)){
	$imageURL = " "; 
}else{
	if (!@getimagesize($imageURL)) {
		echo "Not a valid image. Sent without image!\n";
        $imageURL = " ";
	}else {
        $img_size = get_headers($imageURL, 1)["Content-Length"] / 1048576; //bytes to mb
	    if($img_size > $img_limit) {
            echo "Image too large. Must be under ${img_limit}MB. It is ${img_size}MB. Sent without image!\n";
            $imageURL = " ";
        }
    }
} 

if(empty($link)){ 
	$link = " "; 
}else if (filter_var($link, FILTER_VALIDATE_URL) === FALSE) {
    echo "$link is not a valid link. Sent without link!\n";
	$link = " "; 
}

//check if user exists
if(userExists($con, myHash($credentials))) {

    // store notification encrypted
    $insert_notification_query = mysqli_query($con, "INSERT INTO notifications (credentials, title, message, image, link) VALUES (
        '" . myHash($credentials) . "', 
        AES_ENCRYPT('$title','$key'),
        AES_ENCRYPT('$message','$key'),
        AES_ENCRYPT('$imageURL','$key'),
        AES_ENCRYPT('$link','$key')
    )");

    if ($insert_notification_query) {
        // increment user notification count
        mysqli_query($con, "UPDATE `users`
        SET `notification_cnt` = `notification_cnt` + 1
        WHERE `credentials` = '" . myHash($credentials) . "'");

        // send direct message to user
        $context = new ZMQContext();
        $socket = $context->getSocket(ZMQ::SOCKET_PUSH);
        $socket->connect("tcp://localhost:5555");
        $socket->send(myHash($credentials));
    } else {
        header('HTTP/1.1 500 Internal Server Error');
        echo "Error inserting notification into database!\nPlease send this to max@m4x.co:\n\n" . mysqli_error($con) . "\n\n";
    }
}