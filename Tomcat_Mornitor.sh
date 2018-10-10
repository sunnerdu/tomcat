#!/bin/sh
#date:2018-10-10
#function: monitoring tomcat service down and auto restart it
# obtain tomcat process id (8080 is you monitor java pid) and set dir of starup.sh 
. /etc/profile
TomcatID=$(ps -ef |grep 8080 |grep -v 'grep'|awk '{print $2}')  
StartTomcat=/data/servers/tomcat_8080/bin/startup.sh 
TomcatLog=/data/servers/tomcat_8080/logs/

# Define the page address you want to monitor, and the simpler the page, such as writing success on the page
WebUrl=http://ip:端口/test.jsp

# logging direction （Used to output monitoring logs and monitoring error logs）
mkdir -p /data/servers/tomcat_8080/logs/monitor/

TomcatMonitorLog=/data/servers/tomcat_8080/logs/monitor/TomcatMonitor.log  

GetPageInfo=/data/servers/tomcat_8080/logs/monitor/PageInfo.log

Monitor() 

{  

  echo "[info]开始监控tomcat...[$(date +'%F %H:%M:%S')]"  
  #Determine if the TOMCAT process exists
  if [[ $TomcatID ]];then   

    echo "[info]当前tomcat进程ID为:$TomcatID,继续检测页面..."  

    # Check whether the startup is successful (if successful, the page will return to state "200") 

    TomcatServiceCode=$(curl -s -o $GetPageInfo -m 10 --connect-timeout 10 $WebUrl -w %{http_code})  

    if [ $TomcatServiceCode -eq 200 ];then  

        echo "[info]页面返回码为$TomcatServiceCode,tomcat启动成功,测试页面正常......"  

    else  

        echo "[error]tomcat页面出错,请注意......状态码为$TomcatServiceCode,错误日志已输出到$GetPageInfo"  

        echo "[error]页面访问出错,开始重启tomcat"  

        kill -9 $TomcatID   

        sleep 3  

        rm -rf $TomcatLog  

        $StartTomcat  

    fi  

  else  

    echo "[error]tomcat进程不存在!tomcat开始自动重启..."  

    echo "[info]$StartTomcat,请稍候......"  

    rm -rf $TomcatLog  

    $StartTomcat  

  fi  

  echo "------------------------------"  

}  

Monitor>>$TomcatMonitorLog

