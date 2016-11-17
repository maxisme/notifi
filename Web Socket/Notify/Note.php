<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
require "/NAS/notify/db.php";
 
class Note implements MessageComponentInterface { 
    protected $clients;

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
    }

    public function onMessage(ConnectionInterface $from, $msg) {
		$stack = array(); 
        foreach ($this->clients as $client) {
            if ($from === $client) { //current client only
				$query = getNotifications($msg);
				if($query){
					while($row = mysqli_fetch_assoc($query)){
						array_push($stack, $row);
						deleteNotification($row['id'], $msg);
					}
					$client->send(json_encode($stack));
				}
            }
        }
    }

    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        $conn->close();
    }
}