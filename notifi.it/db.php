<?php
function clean($string) {
   $string = str_replace(' ', '', $string); // removes all spaces
   return preg_replace('/[^A-Za-z0-9\-]/', '', $string);
}

function connect(){
	$db_pass = file_get_contents(dirname(__DIR__)."/db.pass");
	$db_user = file_get_contents(dirname(__DIR__)."/db.user");
	
	$con = mysqli_connect("localhost", "notify", "$db_pass", "$db_user");
	if (!$con) {
		die("error connecting to database");
	} 
	return $con;
}

function getNotifications($credentials){
	$credentials = clean($credentials);
	$key = file_get_contents(dirname(__DIR__)."/encryption.key");
	
	$con = connect();
	$query = mysqli_query($con, "SELECT
	id,
	DATE_FORMAT(time, '%Y-%m-%d %T') as time,
	AES_DECRYPT(credentials, '$key') as credentials,
	AES_DECRYPT(title, '$key') as title, 
	AES_DECRYPT(message, '$key')as message,
	AES_DECRYPT(image, '$key') as image,
	AES_DECRYPT(link, '$key') as link
	FROM `notifications`
	WHERE credentials = AES_ENCRYPT('$credentials', '$key')
	AND title != ''
	");
	
	if(mysqli_num_rows($query) == 0){
		return "";
	}
	
	return $query;
}

function deleteNotification($id, $credentials){
	$credentials = clean($credentials);
	$key = file_get_contents(dirname(__DIR__)."/encryption.key");
	
	$con = connect();
	$id = mysqli_real_escape_string($con, $id);
	mysqli_query($con, "UPDATE `notifications`
	SET title='',message='',image='',link='' 
	WHERE `id`=$id 
	AND `credentials`=AES_ENCRYPT('$credentials', '$key')");
}
?>