#!/bin/bash
CURRENT_PATH=$(cd "$(dirname "$0")";pwd)
cd $CURRENT_PATH
SVR_NAME=$(basename `pwd`)
read -p  "请输入远程主机地址：" REMOTE_HOST
read -p  "请输入登录远程主机地址的账号：" REMOTE_LOGIN_NAME
if [ -n "${REMOTE_LOGIN_NAME}" ];then
 	REMOTE_LOGIN_NAME=${REMOTE_LOGIN_NAME}@
fi
SVR_FILE="/usr/local/$SVR_NAME/stack.yml"
LOC_FILE="$CURRENT_PATH/stack.yml"

echo ===============================
echo 参数详情
echo 远程主机地址：$REMOTE_HOST
echo 远程登录账户：$REMOTE_LOGIN_NAME
echo 微服务的名称：$SVR_NAME
echo ===============================

#判断服务器是否存在stack.yml文件
if ssh ${REMOTE_LOGIN_NAME}${REMOTE_HOST} test -e ${SVR_FILE};then
	echo "服务器已经存在${SVR_FILE}"
else
	#判断本地是否存在stack.yml
	if [  -f "$LOC_FILE" ];then
		echo "本地已存在${LOC_FILE}"
	else
		touch $LOC_FILE
		echo "version: "3.9"" >>$LOC_FILE
		echo "services:" >>$LOC_FILE
		echo "  $SVR_NAME:" >>$LOC_FILE
		read -p "请输入image（xxxx/${SVR_NAME}）：" IMAGE_NAME
		IMAGE="$IMAGE_NAME/$SVR_NAME"
		echo "    image: $IMAGE" >>$LOC_FILE
		echo "    environment:" >>$LOC_FILE
		echo "      - TZ=CST-8" >> $LOC_FILE
		echo "    volumes:" >> $LOC_FILE
		echo "      - /usr/local/$SVR_NAME/config/bootstrap-prod.yml:/usr/local/myservice/config/bootstrap-prod.yml" >> $LOC_FILE
		echo "networks:" >> $LOC_FILE
		echo "  default:" >> $LOC_FILE
		echo "    external: true" >> $LOC_FILE
		echo "    name: rebue" >> $LOC_FILE
		echo "创建本地${LOC_FILE}文件成功！"
	fi
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

if [ -f "$LOC_FILE" ];then
 	rsync --progress -z $LOC_FILE ${REMOTE_LOGIN_NAME}${REMOTE_HOST}:/usr/local/${SVR_NAME}/
fi
echo ===============================
