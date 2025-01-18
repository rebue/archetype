package ${package};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.reactive.config.EnableWebFlux;

import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
@EnableWebFlux
// 如需访问其它微服务，请解开下面的注释
// @EnableFeignClients
@Slf4j
public class ${projectNameCapitalise}Application{

    public static void main(final String[] args) {
        try {
            SpringApplication.run(${projectNameCapitalise}Application.class, args);
        } catch (Throwable e) {
            if (!e.getClass().getName().contains("SilentExitException")) {
                log.error("${artifactId} 启动失败", e);
                throw e;
            }
        }
    }

}