#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import org.springframework.boot.SpringApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.client.SpringCloudApplication;
import org.springframework.web.reactive.config.EnableWebFlux;

@SpringCloudApplication
@EnableCaching
@EnableWebFlux
public class ${projectNameCapitalise}Application {

    public static void main(final String[] args) {
        SpringApplication.run(${projectNameCapitalise}Application.class, args);
    }

}