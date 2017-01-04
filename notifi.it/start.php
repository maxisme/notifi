<?php
require '/var/www/notifi.it/socket/vendor/autoload.php';

use Ratchet\Server\IoServer;
use Notify\Note;

$loop = React\EventLoop\Factory::create();

$note = new Note();
$server = IoServer::factory(
	$note,
	38815
); 

$context = new React\ZMQ\Context($server->loop);
$pull = $context->getSocket(ZMQ::SOCKET_PULL);
$pull->bind('tcp://127.0.0.1:5555');
$pull->on('message', array($note, 'onCurl'));

$server->run();