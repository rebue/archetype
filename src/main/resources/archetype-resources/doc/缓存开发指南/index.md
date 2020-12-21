# 缓存开发指南

在Rebue架构中，主要推荐用 `Spring Cache + Redis` 的方式处理缓存。

1. 引入依赖
   在 `xxx-svr` 项目中引入依赖

    ```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-cache</artifactId>
    </dependency>
    ```

2. 启用缓存
   注意 `xxx-svr` 项目，`XxxApplication.java` 文件，类上方是否有注解 `@EnableCaching`，如没有则添加

3. 取消禁用 **Redis**
   检查 `xxx-svr` 项目，`bootstrap.yml` 文件，是否有下面两行，如有则删除

    ```yml
    spring:
        autoconfigure:
            exclude:
                # 项目中禁用Redis(如果使用了Redis，请删除下面两行)
                - org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration
                - org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration
    ```

4. **Spring Cache** 注解

| 名称         | 说明                                                         |
| :----------- | ------------------------------------------------------------ |
| @CacheConfig | 装饰类，统一此类的缓存配置                                   |
| @Cacheable   | 缓存结果。再次调用，先看缓存中是否存在，不存在才真正调用方法 |
| @CachePut    | 缓存结果。每次都真正调用方法                                 |
| @CacheEvict  | 能够根据一定的条件对缓存进行清空                             |

5. **注意**

- 缓存注解一般写在svc接口层上，请参看 `scx -> sgn -> sgn-svr` 项目的 `SgnSecretSvc` 接口文件中的写法
- 不要直接在类的内部调用缓存的方法，这样缓存会不起作用。应该在接口的实例上调用此方法
- 缓存接口的添加方法要直接传入ID的值，不能由方法里面自动生成，否则缓存失效
