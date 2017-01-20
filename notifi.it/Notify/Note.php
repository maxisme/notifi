<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
//error_reporting(E_ALL);
//ini_set("display_errors", 1);

require "/var/www/notifi.it/socket/db.php";

class Note implements MessageComponentInterface { 
    protected $clients;
	protected $clientCodes = array();

    public function __construct() {
        $this->clients = new \SplObjectStorage; 
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
		echo "\nNew client. Connected from $conn->remoteAddress";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
		if($msg == "ping"){
			foreach ($this->clients as $client) {
				if ($from === $client) { //current client only
					$this->sendNotifications($client);
				}
			}
		}else if(substr($msg,0,3) == "id:"){
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
				echo "\nilegal login from: $credentials with key:\n$key\n";
				$from->send("Invalid Credentials");
				$from->close();
			}

			foreach ($this->clients as $client) {
				if ($from === $client) { //current client only
					$client->clientCode = $credentials;
					$this->sendNotifications($client);
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
				$client->send("--begin--".json_encode($stack)."--end--");

				echo "\n".date("r")." - sent msg:\n".json_encode($stack)." to:$client->clientCode with ip: ".$client->remoteAddress;
			}else{
				$client->send("1");
			}
		}
	}

    public function onClose(ConnectionInterface $conn) {
		echo "connection closed\n";
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
		echo "connection error\n";
        $conn->close();
    }
}