package ${package}.gen;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;

import org.mybatis.generator.exception.InvalidConfigurationException;
import org.mybatis.generator.exception.XMLParserException;

import io.github.codgen.CodgenApplication;
import rebue.mbgx.MybatisGeneratorWrap;

/**
 * 自动生成代码
 */
public class ${projectNameCapitalise}Gen{

    public static void main(String[] args) throws IOException, XMLParserException, SQLException, InterruptedException, InvalidConfigurationException {
        MybatisGeneratorWrap.gen(Path.of("target", "mbgx"), true, null);
        CodgenApplication.main(new String[] { "-i", "src/main/resources/in", "-o", "../" });
    }
}
