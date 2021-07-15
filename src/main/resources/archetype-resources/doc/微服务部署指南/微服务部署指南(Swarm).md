# 微服务部署指南(Swarm)

[TOC]

## 1. 准备项目环境

### 1.1. Dockerfile

在 `xxx-svr` 项目的的 `Dockerfile` 文件，内容如下

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

### 1.2. `xxx-svr` 项目的 `maven-local.properties`

```ini
# 主机名:端口号/xxx
my-docker.host=xxxxx:xxxxx/xxxx
# Docker镜像的前缀(镜像的组织)
docker.image.prefix=rebue
```

### 1.3. `xxx-svr` 项目的 `pom.xml`

- `build` -> `plugins` -> 添加插件

```xml
<!-- 制作docker镜像的插件 -->
<plugin>
  <groupId>com.spotify</groupId>
  <artifactId>dockerfile-maven-plugin</artifactId>
  <executions>
    <execution>
      <id>default</id>
      <!-- 绑定到install阶段执行 -->
      <!-- <phase>install</phase> -->
      <!-- 绑定到deploy阶段执行 -->
      <!-- <phase>deploy</phase> -->
      <!-- 不绑定到任何阶段，也就不会执行 -->
      <phase></phase>
      <goals>
        <goal>build</goal>
        <goal>push</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
    <!-- 此选项指定在settings.xml文件中设置的server -->
    <useMavenSettingsForAuth>true</useMavenSettingsForAuth>
    <!-- 部署到私服，${my-docker.host}在settins.xml中统一配置 -->
    <repository>${my-docker.host}/${docker.image.prefix}/${project.artifactId}</repository>
    <!-- 部署到hub.docker.com -->
    <!-- <repository>{docker.image.prefix}/${project.artifactId}</repository> -->
    <tag>${project.version}</tag>
    <buildArgs>
      <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
    </buildArgs>
    <verbose>true</verbose>
    <googleContainerRegistryEnabled>false</googleContainerRegistryEnabled>
  </configuration>
</plugin>
```

### 1.4. `settings.xml`

```sh
vi ~/.m2/settings.xml
```

```xml
<servers>
    ....

    <!-- Docker私服 -->
    <server>
      <!-- 主机名(可带端口号) -->
      <id>xxxxx</id>
      <username>my-deployment</username>
      <password>xxxxxx</password>
    </server>

    ....
<servers>
```

## 2. 项目打包制作镜像并上传Docker仓库(hubdocker或私服)

启用上节 `pom.xml` 文件中的 `<phase>install</phase>` 节点，然后用 `Maven Build`，`clean install`

- MacOS 注意: 如果报 `java.io.IOException: Cannot run program "docker-credential-osxkeychain"`,
  请 `vi ~/.docker/config.json` 并删除 `"credsStore": "osxkeychain",` 这一行
- 如果报 `Get https://xxxxxx:xxxxx/v2/: http: server gave HTTP response to HTTPS client`
  - MacOS: 请 `vi ~/.docker/daemon.json`
  - 其它Linux: 请 `/etc/docker/daemon.json`
  
  并添加内容如下:

  ```json
  {
    ....

    "insecure-registries": [
      "xxxxxx:xxxx",
      "xxxxxx:xxxx",
    ]

    ....
  }
  ```

  然后重启 Docker

  ```sh
  systemctl daemon-reload
  systemctl restart docker
  ```

## 3. 准备服务器环境

### 3.1. 安装Docker及相关环境

- Docker
  <https://github.com/nnzbz/notes/blob/master/docker/Docker%E5%85%A5%E9%97%A8.md>
- Swarm
  <https://github.com/nnzbz/notes/blob/master/docker/Swarm/Swarm%E7%AE%80%E4%BB%8B.md>

### 3.2. 创建并运行 `Docker` 私服

**注意:** 请使用文档中的 `Swarm` 安装方案
<https://github.com/nnzbz/notes/blob/master/docker/%E5%B8%B8%E7%94%A8%E9%95%9C%E5%83%8F%E4%B8%8E%E5%AE%B9%E5%99%A8/Nexus.md>
<https://github.com/nnzbz/notes/blob/master/docker/Docker%E7%A7%81%E6%9C%8D.md>

### 3.3. 创建虚拟网络

提供给docker容器互联使用

```sh
docker network create -d overlay --attachable rebue
```

### 3.4. 创建并运行常用容器

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

### 3.5. 创建数据库

1. 创建 `schema`
2. 创建账户并授权

   ```sh
   mysql -uroot -p
   ```

   ```sh
   grant all privileges on xxx.* to 'xxx'@'%' identified by '********';
   FLUSH PRIVILEGES;
   ```

- 创建数据库的脚本在 项目下的 `db/script/create-table.sql` 文件中

### 3.6. 在配置中心中配置项目的信息

1. 进入配置中心
  <http://xxxxx:8848/nacos/>
2. 新建配置
  `配置管理` -> `配置列表` -> 点击列表右上角的 `+` 按钮
3. 填写内容并发布
   - Data ID
     xxx-svr-prod.yaml
   - Group
     REBUE
   - 配置格式
     YAML
   - 配置内容
     `xxx-svr` 项目的 `application-prod.yml` 文件的内容，并根据实际情况修改相应内容

### 3.7. `Docker configs`

- 准备 `bootstrap-prod.yml` 文件
  
  ```sh
  vi /usr/local/xxx-svr/bootstrap-prod.yml
  ```

  内容与项目中的同名文件相同

### 3.8. `Docker Compose`

```sh
mkdir -p /usr/local/xxx-svr
vi /usr/local/xxx-svr/stack.yml
```

```yml{.line-numbers}
version: "3.9"
services:
  xxx-svr:
    image: xxx/xxx-svr:x.x.x
    environment:
      # 最好使用此设定时区，其它镜像也可以使用
      - TZ=CST-8
    configs:
      - source: bootstrap-prod.yml
        target: /usr/local/myservice/config/bootstrap-prod.yml
configs:
  bootstrap-prod.yml:
    file: /usr/local/xxx-svr/bootstrap-prod.yml
networks:
  default:
    external: true
    name: rebue
```


## 4. 服务器部署微服务

```sh
docker stack deploy -c /usr/local/xxx-svr/stack.yml xxx-svr
```

## 5. 查看日志

```sh
docker service logs -f xxx-svr_xxx-svr
```
