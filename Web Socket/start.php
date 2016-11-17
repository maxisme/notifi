<?php
require '/NAS/notify/vendor/autoload.php';
 
use Ratchet\Server\IoServer;
use Notify\Note;

$server = IoServer::factory(
	new Note(),
	38815
); 

$server->run();