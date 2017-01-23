<?php
require '/var/www/notifi.it/socket/vendor/autoload.php';

use Ratchet\Server\IoServer;
use Ratchet\WebSocket\WsServer;
use Ratchet\Http\HttpServer;

use Notify\Note;

$note = new Note();
$ws = new WsServer($note);
$ws->disableVersion(0); // old, bad, protocol version

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