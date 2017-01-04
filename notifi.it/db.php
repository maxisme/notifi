<?php
function clean($string) {
   $string = str_replace(' ', '', $string); // removes all spaces
   return preg_replace('/[^A-Za-z0-9\-]/', '', $string);
}

function connect(){
	$db_pass = trim(file_get_contents(dirname(__DIR__)."/db.pass"));
	$db_user = trim(file_get_contents(dirname(__DIR__)."/db.user"));
	
	$con = mysqli_connect("localhost", "$db_user", "$db_pass", 'notifi');
	if (!$con) {
		die("error connecting to database");
	} 
	return $con;
}

function getNotifications($credentials){
	$credentials = clean($credentials);
	$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
	
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
	$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
	
	$con = connect();
	$id = mysqli_real_escape_string($con, $id);
	mysqli_query($con, "DELETE 
	FROM `notifications`
	WHERE `id`=$id 
	AND `credentials`=AES_ENCRYPT('$credentials', '$key')");
}

function isBruteForce($db_user, $db_pass, $key, $credentials = " ", $perMin = 0){
	$ip = $_SERVER['REMOTE_ADDR'];
	$ip_limit = 10;
	$cred_limit = 10;
	$ip_to_cred_limit = 6;
	
	//STORE BRUTE FORCE IP
	$mysqli = new mysqli("localhost", "$db_user", "$db_pass", 'notifi');
	if ($mysqli->connect_error) {
		die('Connect Error (' . $mysqli->connect_errno . ') '. $mysqli->connect_error);
	}

	$stmt = $mysqli->prepare("INSERT INTO `brute_force` (`credentials`, `ip`) VALUES (
	AES_ENCRYPT(?,'$key'), 
	AES_ENCRYPT(?,'$key')
	);");

	$stmt->bind_param('ss', $credentials, $ip);
	$stmt->execute();
	$stmt->close();
	$mysqli->close();
	
	
	//CHECK IF BRUTE FORCE - SELECT - NEEDS TO BE CHANGED TO OBJECT
	$con = connect();
	
	//delete all requests that are over a minute old
	mysqli_query($con, "DELETE
	FROM `brute_force`
	WHERE `time` < date_sub(now(), interval 1 minute)
	"); 


	//limit ammount of requests per ip
	$limit_ip_query = mysqli_query($con, "SELECT id
	FROM `brute_force`
	WHERE ip = AES_ENCRYPT('$ip', '$key')
	AND `time` >= date_sub(now(), interval 1 minute)
	"); 

	if(mysqli_num_rows($limit_ip_query) >= $ip_limit){
		return true;
	}
	
	if($perMin > 0 && mysqli_num_rows($limit_ip_query) > $perMin){
		return true;
	}

	if($credentials != " "){
		//limit ammount of requests per credential
		$limit_cred_query = mysqli_query($con, "SELECT id
		FROM `brute_force`
		WHERE credentials = AES_ENCRYPT('$credentials', '$key')
		AND `time` >= date_sub(now(), interval 1 minute)
		");

		if(mysqli_num_rows($limit_cred_query) >= $cred_limit){
			return true;
		}

		//limit ammount of requests per ip to credential 
		$limit_spec_query = mysqli_query($con, "SELECT id
		FROM `brute_force`
		WHERE credentials = AES_ENCRYPT('$credentials', '$key')
		AND ip = AES_ENCRYPT('$ip', '$key')
		AND `time` >= date_sub(now(), interval 1 minute)
		");

		if(mysqli_num_rows($limit_spec_query) >= $ip_to_cred_limit){
			return true;
		}
	}
	return false;
}

function isValidUser($credentials, $key){
	$encryption_key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
	
	$con = connect();

	$users = mysqli_query($con, "SELECT id
	FROM `users`
	WHERE `credentials` = AES_ENCRYPT('$credentials', '$encryption_key')
	AND `key` = AES_ENCRYPT('$key', '$encryption_key')
	"); 

	if(mysqli_num_rows($users) > 0){
		//update login time
		$time = date('r');
		mysqli_query($con, "UPDATE `users`
		SET `last_login` = '".$time."' 
		WHERE `credentials` = AES_ENCRYPT('$credentials', '$encryption_key')
		AND `key` = AES_ENCRYPT('$key', '$encryption_key')
		"); 
		
		return true;
	}
	
	return false;
}

function userExists($credentials){
	$encryption_key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
	$con = connect();

	$users = mysqli_query($con, "SELECT id
	FROM `users`
	WHERE `credentials` = AES_ENCRYPT('$credentials', '$encryption_key')
	"); 

	if(mysqli_num_rows($users) > 0){
		return true;
	}
	return false;
}

//function encrypt($string){
//	$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
//	
//	$iv = mcrypt_create_iv(
//		mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_CBC),
//		MCRYPT_DEV_URANDOM
//	);
//
//	return base64_encode(
//		$iv .
//		mcrypt_encrypt(
//			MCRYPT_RIJNDAEL_128,
//			hash('sha256', $key, true),
//			$string,
//			MCRYPT_MODE_CBC,
//			$iv
//		)
//	);
//}
//
//function decrypt($string){
//	$key = trim(file_get_contents(dirname(__DIR__)."/encryption.key"));
//	
//	$data = base64_decode($string);
//	$iv = substr($data, 0, mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_CBC));
//
//	return rtrim(
//		mcrypt_decrypt(
//			MCRYPT_RIJNDAEL_128,
//			hash('sha256', $key, true),
//			substr($data, mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_CBC)),
//			MCRYPT_MODE_CBC,
//			$iv
//		),
//		"\0"
//	);
//}
?>