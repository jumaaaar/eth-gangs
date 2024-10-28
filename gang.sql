ALTER TABLE `users` ADD COLUMN `gang` varchar(30) COLLATE utf8mb4_general_ci DEFAULT 'none';
ALTER TABLE `users` ADD COLUMN `gang_rank` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '0';

CREATE TABLE IF NOT EXISTS `eth-gangs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `gangFunds` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

