DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY 'secret-1234' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
CREATE DATABASE IF NOT EXISTS `room_booked` ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;