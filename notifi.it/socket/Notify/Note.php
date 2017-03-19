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

    public function __construct() {
        $this->clients = new \SplObjectStorage; 
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
		echo "New client.";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
		if(substr($msg,0,3) == "id:"){
			//handle reply from user to say they have received notification
			$decrypted_string = decrypt(substr($msg,3,strlen($msg)));
			
			$arr = explode("|", $decrypted_string);
			$id = $arr[0];
			$credentials = $arr[1];
			
			deleteNotification($id, $credentials);
		}else{
			// opening connection message from user

			$arr = explode("|", $msg);
			$credentials = $arr[0];
			$key = $arr[1];

			if(strlen($credentials) != 25){
				$from->close();
			}

			//check if user is valid
			if(!isValidUser($credentials, $key)){
				echo "\nilegal login from: $credentials with key:\n$key";
				$from->send("Invalid Credentials");
				$from->close();
			}

			foreach ($this->clients as $client) {
				if (!isset($client->credential) && $from === $client) { //current client only
					echo myHash($credentials);
					$client->credential = myHash($credentials);
					$this->sendNotifications($client);
					userConnected($client->credential, 1);
				}
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
		echo "\nsend note to: $hashedCredentials";
		if(!empty($hashedCredentials)){
			$query = getNotifications($hashedCredentials);
			if($query != ""){
				$stack = array();
				while($row = mysqli_fetch_assoc($query)){
					array_push($stack, $row);
					$id = $row['id'];
					// client sends this back for server to delete message
					array_push($stack, "id:".encrypt($id."|".$hashedCredentials));
				}
				$client->send(json_encode($stack));
			}else{
				$client->send("1");
			}
		}
	}

    public function onClose(ConnectionInterface $conn) {
		echo "\nconnection closed";
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				userConnected($client->credential, 0);
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