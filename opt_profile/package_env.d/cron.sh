
if [ -e /var/run/cron.pid ]; then
   cron_datetime=`find /var/run/cron.pid -printf "%AY%Am%Ad"`
fi

tday_datetime=`date +%Y%m%d`

if [ ! $cron_datetime = $tday_datetime ] ; then
   echo "Cron must be restart, Please waiting!......."
   cygrunsrv -E cron
   cygrunsrv -S cron
fi
