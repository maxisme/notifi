<?php
session_start();

//---------------EMAIL------------------

//get variables from form
$from = $_POST['email'];
$msg = $_POST['message'];
$name = $_POST['name'];

//validate input
if(strlen($from) == 0){
	$_SESSION["error"] = 1;
	die(header("Location: /#contact"));
}

if(strlen($name) == 0){
	$_SESSION["error"] = 2;
	die(header("Location: /#contact"));
}

if(strlen($msg) == 0){
	$_SESSION["error"] = 3;
	die(header("Location: /#contact"));
}

//validate email
if (!filter_var($from, FILTER_VALIDATE_EMAIL)) {
	$_SESSION["error"] = 4;
	die(header("Location: /#contact"));
}

$email_user = trim(file_get_contents("/var/www/notifi.it/email.user"));
$email_pass = trim(file_get_contents("/var/www/notifi.it/email.pass"));
$email_server = trim(file_get_contents("/var/www/notifi.it/email.server"));

require_once "../../vendor/autoload.php";

$mail = new PHPMailer;

//$mail->SMTPDebug = 2;                               // Enable verbose debug output

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = $email_server;// Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = $email_user;                 // SMTP username
$mail->Password = $email_pass;                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
$mail->Port = 587;                                    // TCP port to connect to

$mail->From = $from;
$mail->FromName = $name;
$mail->addAddress($email_user);

$mail->Subject = "Notifi - Contact form";
$mail->Body    = $msg;

if(!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
	$_SESSION["success"] = 1;
	die(header("Location: /#contact"));
}
?>