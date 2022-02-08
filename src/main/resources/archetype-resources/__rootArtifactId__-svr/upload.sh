#!/bin/bash
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
cd $CURRENT_PATH
SVR_NAME=$(basename `pwd`)
VERSION=$(echo $(perl -lne 'if (/<version>(.*?)<\/version>/){print $1;last;}' pom.xml))
read -p  "请输入远程主机地址：" REMOTE_HOST
read -p  "请输入登录远程主机地址的账号：" REMOTE_LOGIN_NAME
if [ -n "${REMOTE_LOGIN_NAME}" ];then
 	REMOTE_LOGIN_NAME=${REMOTE_LOGIN_NAME}@
fi
SVR_FILE="/usr/local/$SVR_NAME/stack.yml"
LOC_FILE="$CURRENT_PATH/stack.yml"

echo 请选择nacos配置：
NACOS_CONF=
IS_TRUE=true
while $IS_TRUE
do
	echo 1.单机  2.集群  3.自定义
	read NACOS_MODLE
	case ${NACOS_MODLE} in 
		1) 
		NACOS_MODLE="单机"
		NACOS_CONF='nacos1:8848'
		IS_TRUE=false
		;;
		2) 
		NACOS_MODLE="集群"
		IS_TRUE=false
		;;
		3) 
		NACOS_MODLE="自定义"
		read -p  "请输入nacos配置：" CU_NACOS
		NACOS_CONF=$CU_NACOS
		IS_TRUE=false
		;;
		*)
		echo 没有该选项，请重新选择
	esac
done

echo ===============================
echo 参数详情
echo 远程主机地址  ：$REMOTE_HOST
echo 远程登录账户  ：$REMOTE_LOGIN_NAME
echo 微服务的名称  ：$SVR_NAME
echo 微服务的版本  ：$VERSION
echo nacos部署模式 ：$NACOS_MODLE
echo ===============================

# 判断本地是否存在stack.yml
if [  -f "$LOC_FILE" ];then
	echo "本地已存在${LOC_FILE}"
else
	touch $LOC_FILE
	echo "version: \"3.9\"" >>$LOC_FILE
	echo "services:" >>$LOC_FILE
	echo "  svr:" >>$LOC_FILE
	echo "    image: nnzbz/spring-boot-app" >>$LOC_FILE
	echo "    hostname: $SVR_NAME" >>$LOC_FILE
	echo "    init: true" >>$LOC_FILE
	echo "    environment:" >>$LOC_FILE
	echo "      - PROG_ARGS=--spring.profiles.active=prod" >> $LOC_FILE
	echo "      #- JAVA_OPTS=-Xms100M -Xmx100M" >> $LOC_FILE
	echo "    volumes:" >> $LOC_FILE
	echo "      - /usr/local/$SVR_NAME/config/:/usr/local/myservice/config/:z" >> $LOC_FILE
	echo "      - /usr/local/$SVR_NAME/$SVR_NAME-$VERSION.jar:/usr/local/myservice/myservice.jar:z" >> $LOC_FILE
	echo "    deploy:" >> $LOC_FILE
	echo "      placement:" >> $LOC_FILE
	echo "        constraints:" >> $LOC_FILE
	echo "          - node.labels.role==app" >> $LOC_FILE
	echo "      replicas: 1" >> $LOC_FILE
	echo "networks:" >> $LOC_FILE
	echo "  default:" >> $LOC_FILE
	echo "    external: true" >> $LOC_FILE
	echo "    name: rebue" >> $LOC_FILE
	echo "创建本地${LOC_FILE}文件成功！"
fi

rsync --progress -z target/${SVR_NAME}-*.jar ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/ --exclude='*-javadoc.jar' --exclude='*-sources.jar'

rsync --progress -z src/main/resources/config/bootstrap-prod.yml ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/config/

rsync --progress -z src/main/resources/config/log4j2.xml ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/config/

TEMP_FILE="src/main/resources/config/smart-doc.json"
if [ -f "$TEMP_FILE" ];then
 	rsync --progress -z $TEMP_FILE ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/config/
fi

TEMP_DIR="src/main/resources/static"
if [ -d "$TEMP_DIR" ];then
 	rsync -r --progress -z $TEMP_DIR ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/
fi

case ${NACOS_MODLE} in
	'单机')
	ssh $REMOTE_LOGIN_NAME$REMOTE_HOST "sed -i '/server-addr/s/:.*/: ${NACOS_CONF}/g' /usr/local/${SVR_NAME}/config/bootstrap-prod.yml"
	;;
	'集群')
	;;
	'自定义')
	ssh $REMOTE_LOGIN_NAME$REMOTE_HOST "sed -i '/server-addr/s/:.*/: ${NACOS_CONF}/g' /usr/local/${SVR_NAME}/config/bootstrap-prod.yml"
	;;
esac


# 判断服务器是否存在stack.yml文件
if  ssh ${REMOTE_LOGIN_NAME}${REMOTE_HOST} test -e ${SVR_FILE};then
	echo "服务器已经存在${SVR_FILE}"
else
	rsync --progress -z $LOC_FILE ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/
fi

echo ===============================
