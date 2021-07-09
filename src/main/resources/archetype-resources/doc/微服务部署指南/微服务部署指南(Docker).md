# 微服务部署指南(Docker)

[TOC]

如果已经部署，只是Jar包文件升级，只用执行第2步

## 1. (服务器)创建微服务文件存放的目录

```sh
mkdir -p /usr/local/xxx-svr/a
```

## 2. (本地)把打好的Jar包复制到服务器上

```sh
cd xxx/xxx-svr
scp target/xxx-svr-<版本>.jar root@<服务器IP>:/usr/local/xxx-svr
```

## 3. (本地)把项目的资源文件复制到服务器上

```sh
cd xxx/xxx-svr
scp src/main/resources/config/bootstrap.yml root@<服务器IP>:/usr/local/xxx-svr/a/config/
scp src/main/resources/config/bootstrap-prod.yml root@<服务器IP>:/usr/local/xxx-svr/a/config/
scp src/main/resources/config/log4j2.xml root@<服务器IP>:/usr/local/xxx-svr/config/a/config/
```

- 如果资源目录下有templates或static目录，也一样复制，scp的参数加上 `-r`

## 4. (服务器)将jar包链接到分目录下

```sh
cd /usr/local/xxx-svr/
ln xxx.jar a/myservice.jar
```

## 5. (服务器)修改配置文件

```sh
cd /usr/local/xxx-svr/a
# 远程修改为生产模式
sed -i 's/active: dev/active: prod/' config/bootstrap.yml
sed -i 's#config: classpath:config/log4j2.xml#config: config/log4j2.xml#' config/bootstrap-prod.yml
```

- 如果nacos地址不在本机，也请修改为相应的地址(bootstrap-prod.yml文件中)

## 6. (服务器)创建并运行容器

```sh
docker run -d --net=host --name xxx-svr-a -v /usr/local/xxx-svr/a:/usr/local/myservice --restart=always nnzbz/spring-boot-app
```

- JAVA_OPTS
  如需自定义 `JVM内存参数` 等配置，可通过 "-e JAVA_OPTS" 指定，参数格式 `JAVA_OPTS="-Xmx512m"`

## 7. 开启防火墙

```sh
firewall-cmd --permanent --add-port=3xxxx/tcp
firewall-cmd --reload
```

