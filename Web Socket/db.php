<?php
function getNotifications($credentials){
	$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
	$db_user = file_get_contents(dirname(__DIR__)."/db.user");
	$key = file_get_contents(dirname(__DIR__)."/encryption.key");
	
	$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
	if (!$con) {
		die("error connecting to database");
	} 
	
	$query = mysqli_query($con, "SELECT
	id,
	AES_DECRYPT(credentials, '$key') as credentials,
	AES_DECRYPT(title, '$key') as title, 
	AES_DECRYPT(message, '$key')as message,
	AES_DECRYPT(image, '$key') as image,
	AES_DECRYPT(link, '$key') as link
	FROM `notifications`
	WHERE credentials = AES_ENCRYPT('$credentials', '$key')");
	
	if(mysqli_num_rows($query) === 0){
		return "";
	}
	
	return $query;
}

function deleteNotification($id, $credentials){
	$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
	$db_user = file_get_contents(dirname(__DIR__)."/db.user");
	$key = file_get_contents(dirname(__DIR__)."/encryption.key");
	
	$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
	if (!$con) {
		die("error connecting to database");
	}
	
	$id = mysqli_real_escape_string($con, $id);
	
	mysqli_query($con, "DELETE FROM `notifications`
	WHERE `id`=$id 
	AND `credentials`=AES_ENCRYPT('$credentials', '$key')");
}

function storeClient($client_obj, $credentials){
	$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
	$db_user = file_get_contents(dirname(__DIR__)."/db.user");
	$key = file_get_contents(dirname(__DIR__)."/encryption.key");
	
	$mysqli = new mysqli("localhost", "notify", "$db_pass", "$db_user");

	if ($mysqli->connect_error) {
		die('Connect Error (' . $mysqli->connect_errno . ') '
				. $mysqli->connect_error);
	}
	
	$stmt = $mysqli->prepare("INSERT INTO `clients` (client_obj, credentials) VALUES (
	?,?
	)");
	
	$stmt->bind_param('ss', $client_obj, $credentials);
	
	$stmt->execute();
	
	$stmt->close();
	$mysqli->close();
	
	return $stmt->error;
}
?>