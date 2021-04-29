# 消息开发指南

[TOC]

## 1. RabbitMQ 介绍

### 1.1. 原理图

![RabbitMQ原理图](RabbitMQ原理图.png)

- 左侧 **P** 代表 生产者，也就是往 RabbitMQ 发消息的程序
- 中间即是 RabbitMQ 服务器，其中包括了 **交换机** 和 **队列**
- 右侧 **C** 代表 消费者，也就是从 RabbitMQ 拿消息的程序

### 1.2. 重要概念

- 虚拟主机(Virtual Host)
  一个虚拟主机持有一组交换机、队列和绑定。
  为什么需要多个虚拟主机呢？很简单， RabbitMQ 当中，用户只能在虚拟主机的粒度进行权限控制。 因此，如果需要禁止A组访问B组的交换机/队列/绑定，必须为A和B分别创建一个虚拟主机。
  每一个 RabbitMQ 服务器都有一个默认的虚拟主机“/”。
- 交换机(Exchange)
  Exchange 用于转发消息
- 绑定(bind)
  交换机需要和队列相绑定，如上图所示，是多对多的关系。
- 绑定键
  交换机与队列绑定时配置的键
- 路由键
  消息到交换机的时候，交互机会转发到对应的队列中，那么究竟转发到哪个队列，就要根据该消息中的路由键。

**路由键和绑定键的区别:** 绑定键是在绑定时后配置的，路由键是发消息是消息体带的

### 1.3. 交换机(Exchange)详解

- Exchange 用于转发消息，但是它不会做存储，如果没有 Queue bind 到 Exchange 的话，它会直接丢弃掉 Producer 发送过来的消息
- 启用ack模式后，交换机找不到队列会返回错误
- 交换机有4种类型: Direct, Topic, Headers and Fanout
  - Direct：默认模式，”先匹配, 再投送”. 即在绑定时设定一个 routing_key, 消息的routing_key 匹配时, 才会被交换器投送到绑定的队列中去.
  - Topic：按规则转发消息（最灵活）
  - Headers：设置 header attribute 参数类型的交换机
  - Fanout：转发消息到所有绑定队列

#### 1.3.1. Direct Exchange

根据key全文匹配去寻找队列。

![RabbitMQ交换机Direct模式](RabbitMQ交换机Direct模式.png)

- X-Q1 就有一个 binding key，名字为 orange
- X-Q2 就有 2 个 binding key，名字为 black 和 green。
- 当消息中的 路由键 和 这个 binding key 对应上的时候，那么就知道了该消息去到哪一个队列中。
- 为什么 X 到 Q2 要有 black，green，2个 binding key呢，一个不就行了吗？
  这个主要是因为可能又有 Q3，而Q3只接受 black 的信息，而Q2不仅接受black 的信息，还接受 green 的信息。

#### 1.3.2. Topic Exchange

Topic Exchange 转发消息主要是根据通配符。
在这种交换机下，队列和交换机的绑定会定义一种路由模式，那么，通配符就要在这种路由模式和路由键之间匹配后交换机才能转发消息。

下面是该模式下路由键的规则:

- 路由键必须是一串字符，用句号（.） 隔开
  比如说 agreements.us，或者 agreements.eu.stockholm 等。
- 星号（\*）用于匹配一个单词
  比如说，一个路由模式是这样子：agreements..b.*，那么就只能匹配路由键是这样子的：第一个单词是 agreements，第三个单词是 b。
- 井号（#）用于匹配零个或者多个单词
  例如一个匹配模式是 agreements.eu.berlin.#，那么，以agreements.eu.berlin 开头的路由键都是可以的。

消息发送代码示例:

```java
// 第一个参数表示交换机名称，第二个参数表示 routing key，第三个参数即消息
rabbitTemplate.convertAndSend("testTopicExchange","key1.a.c.key2", " this is  RabbitMQ!");
```

Topic 和 Direct 类似, 只是支持 **模糊** 匹配

#### 1.3.3. Headers Exchange

设置 header attribute 参数类型的交换机
和主题交换机有点相似，但是不同于主题交换机的路由是基于路由键，头交换机的路由值基于消息的header数据
主题交换机路由键只有是字符串,而头交换机可以是整型和哈希值
笔者对其使用场景并未深入了解，在此略

#### 1.3.4. Fanout Exchange

Fanout 就是我们熟悉的广播模式或者订阅模式，给 Fanout 交换机发送消息，绑定了这个交换机的所有队列都收到这个消息。

**Fanout交换机如果发消息时使用了 routing_key 会被忽略。**

## 2. 消息可靠投递

### 2.1. 消息投递的路径

`producer` -> `rabbitmq broker cluster` -> `exchange` -> `queue` -> `consumer`

- message 从 `producer` 到 `rabbitmq broker cluster` 则会返回一个 `confirmCallback`
- message 从 `exchange` -> `queue` 投递失败则会返回一个 `returnCallback`

我们将利用这两个 `callback` 控制消息的最终一致性和部分纠错能力。

### 2.2. 开启 ConfirmCallback 和 ReturnCallback

```yaml
spring:
  rabbitmq:
    publisher-confirm-type: SIMPLE 
    publisher-returns: true
```

- publisher-confirm-type有三种类型
  - NONE
    禁用发布确认模式，是默认值
  - CORRELATED
    发布消息成功到交换器后会触发回调方法
  - SIMPLE
    经测试有两种效果，其一效果和CORRELATED值一样会触发回调方法，其二在发布消息成功后使用rabbitTemplate调用waitForConfirms或waitForConfirmsOrDie方法等待broker节点返回发送结果，根据返回结果来判定下一步的逻辑
    注意: waitForConfirmsOrDie方法如果返回false则会关闭channel，则接下来无法发送消息到broker;

### 2.3. ACK模式

监听器要设置自动应答，并且在处理有问题时抛出异常，这样如果出错，就会应答nack，消息还会保留在队列中，以待再次发送

```java
@RabbitListener(ackMode = "AUTO", .....)
```

AcknowledgeMode有三种模式

- NONE
  不应答
- MANUAL
  手动应答
- AUTO
  自动应答(正常返回应答ack/抛出异常应答nack)

## 3. 开发指南

### 3.1. 参考文档

- Spring AMQP 官方文档
  <https://docs.spring.io/spring-amqp/reference/html/>
- Spring AMQP 中文文档
  <https://www.docs4dev.com/docs/zh/spring-amqp/2.1.2.RELEASE/reference>

### 3.2. 项目依赖

```xml
<dependency>
  <groupId>com.github.rebue.sbs</groupId>
  <artifactId>amqp-spring-boot-starter</artifactId>
</dependency>
```

### 3.3. 配置文件

- bootstrap.yaml(发布者才用配置)

  ```yaml
  spring:
    ....
    rabbitmq:
      # 确保消息成功发送到交换器(发布者才用配置)
      publisher-confirm-type: SIMPLE
      # 确保消息在未被队列接收时返回(发布者才用配置)
      publisher-returns: true
  ```

- bootstrap-dev.yaml

  ```yaml
  spring:
    ....
    rabbitmq:
      host: 127.0.0.1
      port: 5672
      username: guest
      password: guest
      virtual-host: /
  ```

- application-prod.yaml

  ```yaml
  spring:
    ....
    rabbitmq:
      host: 127.0.0.1
      port: 5672
      username: guest
      password: guest
      virtual-host: /
  ```

### 3.4. 订阅者程序

- 监听器
  
  ```java
  @Service
  public class XxxSub {

    /**
    * 添加请求日志
    *
    * @param to 添加请求日志的消息体
    */
    @RabbitListener(bindings = @QueueBinding(//
        value = @Queue(XxxAmpqCo.XXXXX), //
        exchange = @Exchange(XxxAmpqCo.XXXXX), //
        key = XxxAmpqCo.XXXXX), //
        ackMode = "AUTO")
    public void addXxx(final XxxTo to) {
        xxxSvc.add(to);
    }

  ```

### 3.5. 发布者工具

```java
public class XxxPubUtils {
    public static void addXxx(final RabbitTemplate rabbitTemplate, final XxxTo to, final Long sendTimeout) {
        // 发送消息
        if (!RabbitTemplateUtils.send(rabbitTemplate, XxxAmpqCo.XXXXX, XxxAmpqCo.XXXXX, to, sendTimeout)) {
            final String msg = "发送XXXXX的消息失败";
            log.error(msg);
            throw new RuntimeException(msg);
        }
    }
}
```

### 3.6. 调用发布者工具的程序

```java
@Service
public class XxxPub {

    @Value("${xxx:5000}")
    private Long           sendTimeout;

    @Resource
    private RabbitTemplate rabbitTemplate;

    public void addXxx(final XxxTo to) {
        RrlPubUtils.addXxx(rabbitTemplate, to, sendTimeout);
    }
}
```
