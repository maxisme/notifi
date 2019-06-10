CREATE DATABASE notifi;
USE notifi;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `credentials` varchar(767) NOT NULL,
  `key` varchar(100) NOT NULL DEFAULT '',
  `last_login` varchar(100) NOT NULL,
  `isConnected` tinyint(1) NOT NULL,
  `app_version` varchar(20) DEFAULT NULL,
  `notification_cnt` int(100) NOT NULL DEFAULT '0',
  `UUID` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `credentials` (`credentials`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `allowed_ips`;
CREATE TABLE `allowed_ips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UUID` varchar(100) DEFAULT NULL,
  `ip` varchar(100) DEFAULT NULL,
  `ip_limit` int(11) NOT NULL DEFAULT '30',
  `cred_limit` int(11) NOT NULL DEFAULT '30',
  `ip_to_cred_limit` int(11) NOT NULL DEFAULT '30',
  PRIMARY KEY (`id`),
  KEY `UUID` (`UUID`),
  CONSTRAINT `allowed_ips_ibfk_UUID` FOREIGN KEY (`UUID`) REFERENCES `users` (`UUID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `brute_force`;

CREATE TABLE `brute_force` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` varchar(100) NOT NULL,
  `credentials` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `crash`;

CREATE TABLE `crash` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `message` text NOT NULL,
  `uuid` varchar(100) NOT NULL DEFAULT '',
  `app_version` varchar(100) DEFAULT NULL,
  `ip` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `notifications`;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `credentials` text NOT NULL,
  `title` text NOT NULL,
  `message` text NOT NULL,
  `image` text NOT NULL,
  `link` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;