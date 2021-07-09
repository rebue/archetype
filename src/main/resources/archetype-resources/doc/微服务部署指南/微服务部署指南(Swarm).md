# 微服务部署指南(Swarm)

[TOC]

## 1. 准备服务器环境

### 1.1. 安装Docker及相关环境

- Docker
  <https://github.com/nnzbz/notes/blob/master/docker/Docker%E5%85%A5%E9%97%A8.md>
- Swarm
  <https://github.com/nnzbz/notes/blob/master/docker/Swarm/Swarm%E7%AE%80%E4%BB%8B.md>

### 1.2. 创建并运行 `Docker` 私服

**注意:** 请使用文档中的 `Swarm` 安装方案
<https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/Nexus.md>
<https://github.com/nnzbz/notes/blob/master/docker/Docker%E7%A7%81%E6%9C%8D.md>

### 1.3. 创建虚拟网络

提供给docker容器互联使用

```sh
docker network create -d overlay --attachable rebue
```

### 1.4. 创建并运行常用容器

**注意:** 请使用文档中的 `Swarm` 安装方案，在 Docker Compose文件中加入如下内容

```yaml
networks:
  default:
    external: true
    name: rebue
```

- Nginx
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/nginx.md>
- ZooKeeper
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/Zookeeper.md>
- MySQL
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/MySQL.md>
- Redis
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/Redis.md>
- RabbitMQ
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/RabbitMQ.md>
- MinIO
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/MinIO.md>
- xxl-job-admin
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/xxl-job-admin.md>
- Nacos
  <https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/Nacos.md>

## 2. 准备项目环境

### 2.1. 项目-配置Docker部署环境

#### 2.1.1. Dockerfile

在 `xxx-svr` 项目的根目录下，新建 `Dockerfile` 文件，内容如下

```Dockerfile
# 基础镜像
FROM nnzbz/spring-boot-app:latest
# 镜像的作者和邮箱
LABEL maintainer="nnzbz@163.com"
# 镜像的版本
LABEL version="x.x.x"
# 镜像的描述
LABEL description="xxx-svr"

# 定义形参，实参可在下列情况下传入
# 1. 在pom.xml文件中的buildArgs节点下定义实参)
# 2. 在docker build命令中以--build-arg a_name=a_value形式赋值
ARG JAR_FILE

# 加入jar包
COPY target/${JAR_FILE} /usr/local/myservice/myservice.jar
# 加入资源
COPY src/main/resources/config/bootstrap.yml /usr/local/myservice/config/bootstrap.yml
COPY src/main/resources/config/bootstrap-prod.yml /usr/local/myservice/config/bootstrap-prod.yml
COPY src/main/resources/config/log4j2.xml /usr/local/myservice/config/log4j2.xml

# 修改为生产模式
RUN sed -i 's/active: dev/active: prod/' config/bootstrap.yml
```

- 修改 `LABEL version="x.x.x"` 为当前项目的版本号
- 修改 `LABEL description="xxx-svr"` 为当前项目名称

