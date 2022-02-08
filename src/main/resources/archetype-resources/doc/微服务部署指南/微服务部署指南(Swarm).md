# 微服务部署指南(Swarm)

[TOC]

## 1. 准备服务器环境

### 1.1. 创建项目数据库

1. 创建 `schema`
2. 创建账户并授权

   下面是命令行的方式，也可以借助可视化管理工具创建

   ```sh
   mysql -uroot -p
   ```

   ```sh
   grant all privileges on xxx.* to 'xxx'@'%' identified by '密码';
   ```

### 1.2. 在配置中心中配置项目的信息

1. 进入配置中心
  <http://xxxxx:8848/nacos/>
2. 新建配置
  `配置管理` -> `配置列表` -> 点击列表右上角的 `+` 按钮
3. 填写内容并发布
   - Data ID
     xxx-svr-prod.yaml
   - 配置格式
     YAML
   - 配置内容
     `xxx-svr` 项目的 `application-prod.yml` 文件的内容，并根据实际情况修改相应内容

## 2. 上传微服务

```sh
# 进入项目的xxx-svr路径
cd xxx/xxx-svr
# 执行上传脚本
./upload.sh
# 填写上传的参数
....
```

## 3. 服务器部署微服务

```sh
docker stack deploy -c /usr/local/xxx-svr/stack.yml xxx
```

## 4. 查看日志

```sh
docker service logs -f xxx_svr
```

## 5. 强制重启服务

```sh
docker service update --force xxx_svr
```

## 6. 调整启动实例个数

```sh
docker service scale xxx_svr=3
```
