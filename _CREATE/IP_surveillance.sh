now_ip="`curl -sS inet-ip.info`"
log_path="/Users/Kureha/Projects/ShProjects/IP_surveillance.log"
echo "NOW IP : $now_ip" > $log_path

while :;do
    chk_ip="`curl -sS inet-ip.info`"
    if [ "$now_ip" != "$chk_ip" ];then
        echo -e "\nIP Changed alarm:" >> $log_path
        echo "  meta IP: $now_ip" >> $log_path
        echo "  now  IP: $chk_ip" >> $log_path
        echo -e "\nNOW IP : $now_ip\n" >> $log_path
        now_ip=$chk_ip
    fi
    sleep 10
done