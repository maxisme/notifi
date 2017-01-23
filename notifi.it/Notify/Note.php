<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
error_reporting(E_ALL);
ini_set("display_errors", 1);

require "/var/www/notifi.it/socket/db.php";

//set all users as not connected in table
$con = connect();
mysqli_query($con, "UPDATE `users`
SET isConnected = 0
"); 

class Note implements MessageComponentInterface { 
    protected $clients;
	protected $clientCodes = array();

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
				if ($from === $client) { //current client only
					$client->clientCode = $credentials;
					$this->sendNotifications($client);
					userConnected($client->clientCode, true);
				}
			}
		} 
    }
	
	public function onCurl($credentials) {
		foreach ($this->clients as $client) {
			if($credentials == $client->clientCode){
				$this->sendNotifications($client);
			}
        }
	}
	
	public function sendNotifications($client){
		$credentials = $client->clientCode;
		if(!empty($credentials)){
			$query = getNotifications($credentials);
			if($query != ""){
				$stack = array();
				while($row = mysqli_fetch_assoc($query)){
					array_push($stack, $row);
					$id = $row['id'];
					array_push($stack,"id:".encrypt($id."|".$credentials));
				}
				$client->send(json_encode($stack));

				echo "\n".date("r")." - sent message to:$client->clientCode";
			}else{
				$client->send("1");
			}
		}
	}

    public function onClose(ConnectionInterface $conn) {
		echo "\nconnection closed";
		foreach($this->clients as $client){
			userConnected($client->clientCode, false);
		}
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
		echo "\nconnection error:";
		print_r($e);
        $conn->close();
    }
}