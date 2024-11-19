apt install mariadb-server -y
vi /etc/mysql/mariadb.conf.d/50-server.cnf
bind-address            = 0.0.0.0

systemctl restart  mariadb


$ pwd && ls
/home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts
$ mysql
MariaDB [(none)]> source /home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts/01-create-user.sql 
MariaDB [(none)]> source /home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts/02-create-products.sql
MariaDB [full-stack-ecommerce]> source /home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts/03-refresh-database-with-100-products.sql
MariaDB [full-stack-ecommerce]> source /home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts/04-countries-and-states.sql
MariaDB [full-stack-ecommerce]> source /home/viettu/Fullstack-Ecommerce-Web/01-starter-files_db-scripts/05-create-order-tables.sql

