<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
error_reporting(E_ALL);
ini_set("display_errors", 1);

require "/var/www/notifi.it/public_html/functions.php";

//set all users as not connected in table
$con = connect();
mysqli_query($con, "UPDATE `users`
SET isConnected = 0
");


class Note implements MessageComponentInterface { 
    protected $clients;
	protected $credential;
    private $delete_str = "id:";

    public function __construct() {
        $this->clients = new \SplObjectStorage; 
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
		echo "New client.";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $con = connect();
        $msg = mysqli_real_escape_string($con, $msg);

		if(substr($msg,0, strlen($this->delete_str)) == $this->delete_str){
			//handle reply from user to say they have received notification
			$decrypted_string = decrypt(base64_decode(substr($msg, strlen($this->delete_str), strlen($msg))));
			
			$arr = explode("|", $decrypted_string);
			$id = $arr[0];
			$credentials = $arr[1];
			
			deleteNotification($con, $id, $credentials);
		}else{
			// opening connection message from user
			$arr = explode("|", $msg);
			$credentials = $arr[0];
			$key = $arr[1];
            $UUID = $arr[2];
            $app_version = $arr[3];

            if(empty($app_version) || !preg_match("/^\d*\.\d*$/", $app_version)){
                $from->send("Invalid app_version");
                $from->close();
            }

            if(empty($UUID) || !validUUID($UUID)){
                $from->send("Invalid UUID");
                $from->close();
            }

			if(strlen($credentials) != 25){
				$from->close();
			}else if(isValidUser($con, $credentials, $key, $UUID, $app_version)){
			    //VALID USER
                foreach ($this->clients as $client) {
                    if (!isset($client->credential) && $from === $client) { //current client only
                        $client->credential = myHash($credentials);
                        $client->send("1"); // authorised message
                        $this->sendNotifications($client);
                        userConnected($client->credential, 1);
                    }
                }
			}else {
                echo "\nilegal login from: $credentials with key:\n$key and UUID:\n$UUID";
                $from->send("Invalid Credentials");
                $from->close();
            }
		} 
    }
	
	public function onCurl($hashedCredentials) {
		foreach ($this->clients as $client) {
			if(isset($client->credential) && $hashedCredentials == $client->credential){
				$this->sendNotifications($client);
			}
        }
	}
	
	public function sendNotifications($client){
		$hashedCredentials = $client->credential;
		if(!empty($hashedCredentials)){
			$query = getNotifications($hashedCredentials);
			if($query != ""){
				$stack = array();
				while($row = mysqli_fetch_assoc($query)){
					array_push($stack, $row);
					$id = $row['id'];
					// client sends this back for server to delete message
					array_push($stack, $this->delete_str.base64_encode(encrypt($id."|".$hashedCredentials)));
				}
				$client->send(json_encode($stack));
			}
		}
	}

    public function onClose(ConnectionInterface $conn) {
		echo "\nconnection closed";
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				userConnected($client->credential, 0);
                $client->credential = NULL;
			}
		} 
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
		echo "\nconnection error:";
		print_r($e);
        $conn->close();
    }
}