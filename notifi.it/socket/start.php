<?php
require __DIR__ . '/vendor/autoload.php';

use Ratchet\Server\IoServer;
use Ratchet\WebSocket\WsServer;
use Ratchet\Http\HttpServer;

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

error_reporting(E_ALL);
ini_set("display_errors", 1);

require "functions.php";

//set all users as not connected in table
$con = connect();
mysqli_query($con, "UPDATE `users`
SET isConnected = 0
");
mysqli_close($con);


class Note implements MessageComponentInterface
{
    protected $clients;
    protected $credential;
    private $delete_str = "id:";
    private $server_key;

    public function __construct()
    {
        // server_key is used to verify that web socket connection is coming from MacOS app
        $this->server_key = file_get_contents("/secret_server_code.pass");
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn)
    {
        try {
            if ($conn->WebSocket->request->getHeader('Sec-Key') != $this->server_key) {
                $conn->close();
            } else {
                $this->clients->attach($conn);
            }
        } catch (Throwable $t) {
            $conn->close();
        }
    }

    public function onMessage(ConnectionInterface $from, $msg)
    {
        $con = connect();

        if (substr($msg, 0, strlen($this->delete_str)) == $this->delete_str) {
            //handle confirmation message from user to say they have received notification
            $msg = mysqli_real_escape_string($con, $msg);
            $decrypted_string = decrypt(base64_decode(substr($msg, strlen($this->delete_str), strlen($msg))));

            $arr = explode("|", $decrypted_string);
            if (count($arr) != 2) $from->close();
            $id = $arr[0];
            $credentials = $arr[1];

            deleteNotification($con, $id, $credentials);
        } else {
            $json = json_decode($msg);

            if (json_last_error() != JSON_ERROR_NONE) $from->close();

            $credentials = $json->credentials;
            $key = $json->key;
            $UUID = $json->UUID;
            $app_version = $json->app_version;

            if (empty($app_version) || !preg_match("/^\d*\.\d*$/", $app_version)) {
                echo "invalid app version";
                $from->send("Invalid app_version");
                $from->close();
            }

            if (empty($UUID) || !validUUID($UUID)) {
                $from->send("Invalid UUID");
                $from->close();
            }

            if (strlen($credentials) != 25) {
                $from->send("Invalid Credentials");
                $from->close();
            } else if (isValidUser($con, $credentials, $key, $UUID, $app_version)) {
                //VALID USER
                foreach ($this->clients as $client) {
                    if (!isset($client->credential) && $from === $client) { //current client only
                        $client->credential = myHash($credentials);
                        $client->send("1"); // authorised message
                        $this->sendNotifications($client);
                        userConnected($client->credential, 1);
                    }
                }
            } else {
                echo "\nilegal login from: $credentials with key:\n$key and UUID:\n$UUID";
                $from->send("Invalid Credentials");
                $from->close();
            }
        }

        mysqli_close($con);
    }

    public function onCurl($hashedCredentials)
    {
        foreach ($this->clients as $client) {
            if (isset($client->credential) && $hashedCredentials == $client->credential) {
                $this->sendNotifications($client);
            }
        }
    }

    public function sendNotifications($client)
    {
        $hashedCredentials = $client->credential;
        if (!empty($hashedCredentials)) {
            $query = getNotifications($hashedCredentials);
            if ($query != "") {
                $stack = array();
                while ($row = mysqli_fetch_assoc($query)) {
                    array_push($stack, $row);
                    $id = $row['id'];
                    // client sends this back for server to delete message
                    $delete_message = $this->delete_str . base64_encode(encrypt($id . "|" . $hashedCredentials));
                    array_push($stack, $delete_message);
                }
                $client->send(json_encode($stack));
            }
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        echo "\nconnection closed";
        foreach ($this->clients as $client) {
            if ($conn == $client) {
                userConnected($client->credential, 0);
                $client->credential = NULL;
            }
        }
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        echo "\nconnection error:";
        print_r($e);
        $conn->close();
    }
}

// remote server
$note = new Note();
$ws = new WsServer($note);
//$ws->disableVersion(0); // old, bad, protocol version
$server = IoServer::factory(
    new HttpServer($ws),
    1203
);

//local socket for on curl requests to Ratchet socket
$context = new React\ZMQ\Context($server->loop);
$pull = $context->getSocket(ZMQ::SOCKET_PULL);
$pull->bind('tcp://127.0.0.1:5555');
$pull->on('message', array($note, 'onCurl'));

$server->run();