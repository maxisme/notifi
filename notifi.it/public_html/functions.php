<?php
function clean($string) {
   $string = str_replace(' ', '', $string); // removes all spaces
   return preg_replace('/[^A-Za-z0-9\-]/', '', $string);
}

function connect(){
	$db_pass = trim(file_get_contents("/var/www/notifi.it/db.pass"));
	$db_user = trim(file_get_contents("/var/www/notifi.it/db.user"));
	
	$con = mysqli_connect("127.0.0.1", "$db_user", "$db_pass", 'notifi');
	if (!$con) {
		die("error connecting to database");
	} 
	return $con; 
}

function getNotifications($hashedCredentials){
	$hashedCredentials = clean($hashedCredentials);
	$key = trim(file_get_contents("/var/www/notifi.it/encryption.key"));
	
	$con = connect();
	$query = mysqli_query($con, "SELECT
	id,
	DATE_FORMAT(time, '%Y-%m-%d %T') as time,
	AES_DECRYPT(title, '$key') as title, 
	AES_DECRYPT(message, '$key')as message,
	AES_DECRYPT(image, '$key') as image,
	AES_DECRYPT(link, '$key') as link
	FROM `notifications`
	WHERE credentials = '$hashedCredentials'
	AND title != ''
	ORDER BY time ASC
	");

	if(mysqli_num_rows($query) == 0){
		return "";
	}
	
	return $query;
}

function deleteNotification($con, $id, $credentials){
	$credentials = clean($credentials);
	$id = mysqli_real_escape_string($con, $id);

	mysqli_query($con, "DELETE 
	FROM `notifications`
	WHERE `id`=$id 
	AND `credentials`= '$credentials'");
}

function isBruteForce($con, $credentials = " "){
	$ip = $_SERVER['REMOTE_ADDR'];
	//limits per min
	$ip_limit = 20; // max a specific IP is alowed to send
	$cred_limit = 10; // max a user is allowed to receive
	$ip_to_cred_limit = 5; // max a specific IP to specific credentials

    // validation - pointless MAYBE
    if (!filter_var($ip, FILTER_VALIDATE_IP)) {
        return true;
    }

    // ----- db admin ----
	//STORE BRUTE FORCE IP
	mysqli_query($con, "INSERT INTO `brute_force` 
	(`credentials`, `ip`) 
	VALUES ('".myHash($credentials)."', '".myHash($ip)."')");
	
	//delete all requests that are over a minute old
	mysqli_query($con, "DELETE
	FROM `brute_force`
	WHERE `time` < date_sub(now(), interval 1 minute)
	");

    // ----- checks ----

    // check if ip is in whitelist
    $whitelist_ip_query = mysqli_query($con,"SELECT ip_limit, cred_limit, ip_to_cred_limit
    FROM `allowed_ips`
    INNER JOIN `users`
    on `users`.UUID = `allowed_ips`.UUID
    WHERE `allowed_ips`.ip = '$ip'
    AND `users`.credentials = '".myHash($credentials)."'");

    while ($row = mysqli_fetch_array($whitelist_ip_query)) {
        $ip_limit = $row['ip_limit'];
        $cred_limit = $row['cred_limit'];
        $ip_to_cred_limit = $row['ip_to_cred_limit'];
        break;
    }

	// $ip_limit
	$limit_ip_query = mysqli_query($con, "SELECT id
	FROM `brute_force`
	WHERE ip = '".myHash($ip)."'
	AND `time` >= date_sub(now(), interval 1 minute)
	"); 

	if(mysqli_num_rows($limit_ip_query) > $ip_limit){
		return true;
	}

	if($credentials != " "){
		// $cred_limit
		$limit_cred_query = mysqli_query($con, "SELECT id
		FROM `brute_force`
		WHERE credentials = '".myHash($credentials)."'
		AND `time` >= date_sub(now(), interval 1 minute)
		");

		if(mysqli_num_rows($limit_cred_query) > $cred_limit){
			return true;
		} 

		// $ip_to_cred_limit
		$limit_spec_query = mysqli_query($con, "SELECT id
		FROM `brute_force`
		WHERE credentials = '".myHash($credentials)."'
		AND ip = '".myHash($ip)."'
		AND `time` >= date_sub(now(), interval 1 minute)
		");

		if(mysqli_num_rows($limit_spec_query) > $ip_to_cred_limit){
			return true;
		}
	}

	return false;
}

function isValidUser($con, $credentials, $key, $UUID, $app_version){
	$where_statement = "WHERE `credentials` = '".myHash($credentials)."'
	AND `key` = '".myHash($key)."'
	AND `UUID` = '".myHash($UUID)."'";

	// MySQL statements
	$users = mysqli_query($con, "SELECT id
	FROM `users` 
	$where_statement
	");

	if(mysqli_num_rows($users) > 0){
		//update login time
        $query = mysqli_query($con, "UPDATE `users`
		SET `last_login` = now(), `app_version` = '$app_version'
		$where_statement
		");
		return $query;
	}
	return false;
}

function userExists($con, $hashedCredentials){
	$users = mysqli_query($con, "SELECT id
	FROM `users`
	WHERE `credentials` = '$hashedCredentials'
	");

    return mysqli_num_rows($users) > 0;
}

function userConnected($hashedCredentials, $isConnected){
    $con = connect();
	$isConnected = (int)$isConnected;
	
	return mysqli_query($con, "UPDATE `users`
	SET isConnected = '$isConnected'
	WHERE `credentials` = '$hashedCredentials'
	"); 
}

//--------- extra functions
function randomString($length) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function encrypt($string){
	$tag_length = 16;
	$algo = 'aes-256-gcm';

	$tag = random_bytes($tag_length);
	$iv   = random_bytes(openssl_cipher_iv_length($algo));
	$key = trim(file_get_contents("/var/www/notifi.it/encryption.key"));

	$encr = openssl_encrypt(
		$string,
		$algo,
		$key,
		OPENSSL_RAW_DATA,
		$iv,
		$tag
	);

	//echo "tag: $tag<br>iv:$iv<br>encr:$encr";

	return utf8_encode($tag.$iv.$encr);
}

function decrypt($string){
	$string = utf8_decode($string);

	$tag_length = 16;
	$algo = 'aes-256-gcm';

	$key = trim(file_get_contents("/var/www/notifi.it/encryption.key"));
	$iv_size = openssl_cipher_iv_length($algo);

	$tag = substr($string, 0, $tag_length);
	$iv = substr($string, $tag_length, $iv_size);
	$ciphertext = substr($string,$tag_length + $iv_size);

	//echo "tag: $tag<br>iv:$iv<br>encr:$ciphertext";

	return openssl_decrypt(
		$ciphertext,
		$algo,
		$key,
		OPENSSL_RAW_DATA,
		$iv,
		$tag
	);
}

function myHash($str){
	return hash("sha256",$str);
}

function validUUID($UUID){
    return preg_match('/^\{?[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}\}?$/', $UUID);
}
?>