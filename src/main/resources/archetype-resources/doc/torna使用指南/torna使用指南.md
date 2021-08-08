# torna使用指南

## 1. 部署


## 2. 浏览器访问

<http://127.0.0.1:7700>

**注意:** 如果是部署到了其它服务器上，请将 `127.0.0.1` 改为相应的服务器地址

## 3. 体验账号

```ini
密码均为：123456

超级管理员：admin@torna.cn

研发一部空间管理员：dev1admin@torna.cn
研发一部-商城项目（公开）-项目管理员：dev1shop_admin@torna.cn
研发一部-商城项目（公开）-开发者张三：dev1shop_zhangsan@torna.cn
研发一部-访客王五：dev1guest_wangwu@torna.cn


研发二部空间管理员：dev2admin@torna.cn
研发二部-后台项目（私有）-项目管理员：dev2back_admin@torna.cn
研发二部-后台项目（私有）-开发者李四：dev2back_lisi@torna.cn
研发二部-后台项目（私有）-访客：dev2back_guest@torna.cn
研发二部-访客赵六：dev2guest_zhaoliu@torna.cn
```

## 4. 使用指南

1. 使用上面的超级管理员账号登录系统
2. 创建空间(一般以公司名称或小组名称命名)
3. 进入空间，创建项目
4. 进入项目，创建模块 `xxx-svr`
5. 在 `xxx-svr` 的 `smart-doc.json` 文件中添加内容如下:

   ```json
   {
       ....
       "appKey": "20210617855105369637126144",              // torna平台对接appKey，在 空间->开放用户 中查看
       "secret": "71T56-65R2Hc>Afu2YfBRcogROjezZTD",        // torna平台secret，在 空间->开放用户 中查看
       "appToken": "98ee93e2bfb747658fa818572f60cc50",      // torna平台appToken，在 项目->模块->OpenAPI 中查看
       "openUrl": "http://127.0.0.1:7700/api",              // torna平台地址，填写自己的私有化部署地址
       "debugEnvName": "测试环境",                           // torna环境名称(正式/测试)
       "debugEnvUrl": "http://127.0.0.1:xxxxx"              // torna测试调用微服务的地址
   }
   ```

6. 使用 `Maven Build` 编译 `xxx` 项目，`Goals` 的参数填 `smart-doc:torna-rest`，编译出文档并推送到 `torna` 服务器
