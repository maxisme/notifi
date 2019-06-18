DROP TABLE IF EXISTS `users`;

CREATE TABLE `users`
(
    `id`               int(11)      NOT NULL AUTO_INCREMENT,
    `created`          timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `credentials`      varchar(60)  NOT NULL,
    `credential_key`   varchar(200) NOT NULL DEFAULT '',
    `last_login`       varchar(100)          DEFAULT NULL,
    `is_connected`     tinyint(1)   NOT NULL DEFAULT '0',
    `app_version`      varchar(20)           DEFAULT NULL,
    `notification_cnt` int(100)     NOT NULL DEFAULT '0',
    `UUID`             varchar(60)           DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `credentials` (`credentials`),
    UNIQUE KEY `UUID` (`UUID`)
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

DROP TABLE IF EXISTS `crash`;

CREATE TABLE `crash`
(
    `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
    `timestamp`   timestamp        NULL DEFAULT CURRENT_TIMESTAMP,
    `message`     text             NOT NULL,
    `UUID`        varchar(60)           DEFAULT NULL,
    `app_version` varchar(100)          DEFAULT NULL,
    `ip`          varchar(100)          DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

DROP TABLE IF EXISTS `notifications`;

CREATE TABLE `notifications`
(
    `id`          int(11)        NOT NULL AUTO_INCREMENT,
    `time`        timestamp      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `credentials` varchar(60)    NOT NULL,
    `title`       varchar(1000)  NOT NULL,
    `message`     varchar(10000) NOT NULL,
    `image`       varchar(4000)  NOT NULL,
    `link`        varchar(4000)  NOT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `credentials` FOREIGN KEY (`credentials`) REFERENCES `users` (`credentials`)
) ENGINE = InnoDB
  DEFAULT CHARSET = latin1;