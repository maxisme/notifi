<?php
require "functions.php";

$con = connect();

if((string)$_POST['server_key'] != file_get_contents("../secret_server_code.pass")) die("Invalid Server Key");

if(isBruteForce($con)) die("\nToo many requests from IP address try again in 1 minute!");

$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
if(!validUUID($UUID)) die("Invalid UUID");

//get unique credentials
do {
    $credentials = "SCqJj4PDPwJtUbn9qyAV6ftFv";
    $key = randomString($key_length);

    // check if credentials are already in database
    $result_user = mysqli_query($con, "SELECT `id`
    FROM `users`
    WHERE `credentials` = '" . myHash($credentials) . "'
    ");
}while(mysqli_num_rows($result_user) != 0);

//check if UUID (client) already exists
$UUID_query = mysqli_query($con, "SELECT *
FROM `users`
WHERE `UUID` = '" . myHash($UUID) . "'
");

if(mysqli_num_rows($UUID_query) != 0) {
    while ($row = mysqli_fetch_array($UUID_query)) {
        // empty checks means we can delete content from db and user can reset without
        // knowing credentials or key
        if(!empty($row['credentials']) && $row['credentials'] != myHash(@$_POST['current_credentials'])) die("1");
        if(!empty($row['key']) && $row['key'] != myHash(@$_POST['current_key'])) die("1");
        break;
    }
    //update UUID user - in turn deletes unused credentials
    mysqli_query($con, "UPDATE `users`
    SET `credentials` = '" . myHash($credentials) . "', `key` = '" . myHash($key) . "', `created` = now()
    WHERE `UUID` = '" . myHash($UUID) . "'");
}else {
    //create new user
    mysqli_query($con, "INSERT INTO `users` (`credentials`, `key`, `UUID`) VALUES (
        '" . myHash($credentials) . "', '" . myHash($key) . "', '" . myHash($UUID) . "'
    );");
}

die(json_encode(array(
    "key" => $key,
    "credentials" => $credentials
)));