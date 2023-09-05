mysql_option="--defaults-extra-file=/home/.mycnf/local_root.cnf"

for file in 2023/struct/*.sql
do
    db=$(echo $file | sed 's/2023\/struct\///g' | sed 's/.sql//g')
    echo $db 'Struct'
    mysql $mysql_option -e "DROP DATABASE IF EXISTS $db;CREATE DATABASE $db;"
    mysql $mysql_option -f $db < $file
done

for file in 2023/data/*.sql
do
    db=$(echo $file | sed 's/2023\/data\///g' | sed 's/.sql//g')
    echo $db 'Data'
    mysql $mysql_option $db -f  < $file
done
