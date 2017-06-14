<?php
require "functions.php";

$con = connect();

if(isBruteForce($con)) die("\nToo many requests from IP address try again in 1 minute!");

$UUID = mysqli_real_escape_string($con, $_POST['UUID']);

//get unique credentials
do {
    $credentials = "SCqJj4PDPwJtUbn9qyAV6ftFv";
    $key = randomString(100);

    // check if user is already in database
    $result_user = mysqli_query($con, "SELECT `id`
    FROM `users`
    WHERE `credentials` = '" . myHash($credentials) . "'
    ");
}while(mysqli_num_rows($result_user) != 0);

//check if UUID (client) already exists
$UUID_query = mysqli_query($con, "SELECT `id`
FROM `users`
WHERE `UUID` = '" . myHash($UUID) . "'
");

if(mysqli_num_rows($UUID_query) != 0) {
    while ($row = mysqli_fetch_array($UUID_query)) {
        $id = $row['id'];
        break;
    }
    //update UUID user - in turn deletes unused credentials
    mysqli_query($con, "UPDATE `users`
    SET `credentials` = '" . myHash($credentials) . "', `key` = '" . myHash($key) . "', `created` = now()
    WHERE `id` = '" . $id . "'");
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