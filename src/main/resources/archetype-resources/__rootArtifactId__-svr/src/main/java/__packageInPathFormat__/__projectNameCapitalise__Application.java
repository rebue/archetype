package ${package};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.reactive.config.EnableWebFlux;

@SpringBootApplication
@EnableWebFlux
// 如需访问其它微服务，请解开下面的注释
//@EnableFeignClients
public class ${projectNameCapitalise}Application {

    public static void main(final String[] args) {
        try {
            SpringApplication.run(AdmApplication.class, args);
        } catch (Throwable e) {
            e.printStackTrace();
            throw e;
        }
    }

}