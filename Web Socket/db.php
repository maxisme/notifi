<?php
function getNotifications($credentials){
	$db_pass = file_get_contents("../db.pass");
	$db_user = file_get_contents("../db.user");
	$key = file_get_contents("../encryption.key");
	
	$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
	if (!$con) {
		die("error connecting to database");
	} 
	
	$query = mysqli_query($con, "SELECT
	id,
	AES_DECRYPT(title, '$key') as title, 
	AES_DECRYPT(message, '$key')as message,
	AES_DECRYPT(image, '$key') as image,
	AES_DECRYPT(link, '$key') as link
	FROM `notifications`
	WHERE credentials = AES_ENCRYPT('$credentials', '$key')");
	
	return $query;
}

function deleteNotification($id, $credentials){
	$db_pass = file_get_contents("../db.pass");
	$db_user = file_get_contents("../db.user");
	$key = file_get_contents("../encryption.key");
	
	$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
	if (!$con) {
		die("error connecting to database");
	}
	
	$id = mysqli_real_escape_string($con, $id);
	
	mysqli_query($con, "DELETE FROM `notifications`
	WHERE `id`=$id 
	AND `credentials`=AES_ENCRYPT('$credentials', '$key')");
}
?>