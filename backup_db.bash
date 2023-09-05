mysql_opt="--defaults-extra-file=/home/.mycnf/server_root.cnf"

calcdatetime=$(perl -MPOSIX -we "print POSIX::strftime(\"%Y%m%d\", localtime(time-8*60*60))")
calcdatetime='00000000'

gitdate=$(date +%Y%m%d)


base_dir="/backup/backup_target/$(date +%Y)"
import_dir="${base_dir}/import"
struct_dir="${base_dir}/struct"
data_dir="${base_dir}/data"

if [ -d "$base_dir" ]
then
        rm -f ${data_dir}/*.sql
        rm -f ${struct_dir}/*.sql
        echo $(date +%Y.%m.%d_%H.%M.%s) > ${base_dir}/timestamp.txt
else
        mkdir $base_dir
        git init $base_dir
        ##
        mkdir ${struct_dir}
        mkdir ${data_dir}
        echo $(date +%Y.%m.%d_%H.%M.%s) > ${base_dir}/timestamp.txt
fi

qry="SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME NOT IN ('information_schema','performance_schema','sys','mysql') AND SCHEMA_NAME NOT LIKE 'dbx%' ORDER BY SCHEMA_NAME"
DBS=$(mysql $mysql_opt -Bse "$qry")

for db in $DBS
do
        mysqldump $mysql_opt --single-transaction=TRUE -d -f --default-character-set=utf8 --routines --no-tablespaces $db > "${struct_dir}/$db.sql"
done

for db in db1 db2 db3
do
        mysqldump $mysql_opt --no-create-info --default-character-set=utf8 --skip-triggers --compact  $db > ${data_dir}/$db.sql
done


git -C $base_dir add .
git -C $base_dir commit -am ${gitdate}
git -C $base_dir tag -a ${gitdate} -m $gitdate
