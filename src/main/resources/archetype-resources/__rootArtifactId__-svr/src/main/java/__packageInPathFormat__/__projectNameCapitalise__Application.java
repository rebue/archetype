#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
package ${package};

import org.springframework.boot.SpringApplication;
import org.springframework.cloud.client.SpringCloudApplication;

@SpringCloudApplication
public class ${projectNameCapitalise}Application {

    public static void main(final String[] args) {
        SpringApplication.run(${projectNameCapitalise}Application.class, args);
    }

}