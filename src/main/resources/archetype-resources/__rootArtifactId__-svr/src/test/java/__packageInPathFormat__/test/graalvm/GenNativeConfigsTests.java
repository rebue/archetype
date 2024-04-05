package ${package}.test.graalvm;

import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Slf4j
public class GenNativeConfigsTests {
    @Test
    public void test() {
        log.info("general native config files.");
    }
}
