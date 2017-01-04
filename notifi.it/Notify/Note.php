<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
error_reporting(E_ALL);
ini_set("display_errors", 1);

require "/var/www/notifi.it/socket/db.php";

class Note implements MessageComponentInterface { 
    protected $clients;
	protected $clientCodes = array();

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
		echo "\nnew client";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
		$arr = explode("|", $msg);
		$credentials = $arr[0];
		$key = $arr[1];
		
		if(strlen($credentials) != 25){
			$from->close();
		}
		
		//check if user is valid
		if(!isValidUser($credentials, $key)){
			echo "ilegal login";
			$from->close();
		}
		
		$x = 0;
        foreach ($this->clients as $client) {
            if ($from === $client) { //current client only
				$this->clientCodes[$x] = $credentials;
				echo "\nmsg:$credentials from: ".$client->remoteAddress;
				$query = getNotifications($credentials);
				if($query != ""){
					$stack = array();
					while($row = mysqli_fetch_assoc($query)){
						array_push($stack, $row);
						deleteNotification($row['id'], $credentials);
					}
					$client->send(json_encode($stack));
				}else{
					$client->send("1");
				}
            }
			$x++;
        }
    }
	
	public function onCurl($msg) {
		$x = 0;
		foreach ($this->clients as $client) {
			if($msg == $this->clientCodes[$x]){
				$stack = array();
				$query = getNotifications($msg);
				//echo "\ncurl msg:$msg from: ".$client->remoteAddress;
				if($query != ""){
					while($row = mysqli_fetch_assoc($query)){
						array_push($stack, $row);
						deleteNotification($row['id'], $msg);
					}
					$client->send(json_encode($stack));
				}
			}
			$x++;
        }
	}

    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        $conn->close();
    }
}