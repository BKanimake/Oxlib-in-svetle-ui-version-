CREATE TABLE IF NOT EXISTS `player_skills` (
  `citizenid` VARCHAR(50) NOT NULL,
  `scavenging` INT DEFAULT 0,
  `gunsmithing` INT DEFAULT 0,
  `survival` INT DEFAULT 0,
  `engineering` INT DEFAULT 0,
  `skill_points` INT DEFAULT 0,
  `unlocked_nodes` LONGTEXT DEFAULT '[]',
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
