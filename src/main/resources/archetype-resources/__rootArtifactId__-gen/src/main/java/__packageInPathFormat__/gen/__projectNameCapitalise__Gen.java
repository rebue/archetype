package ${package}.gen;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.SQLException;

import org.mybatis.generator.exception.InvalidConfigurationException;
import org.mybatis.generator.exception.XMLParserException;

import io.github.codgen.CodgenApplication;
import io.github.codgen.java.CodgenJavaApplication;
import rebue.mbgx.MybatisGeneratorWrap;

/**
 * 自动生成代码
 */
public class ${projectNameCapitalise}Gen{

    public static void main(String[] args) throws IOException, XMLParserException, SQLException, InterruptedException, InvalidConfigurationException {
        // 先根据mbgx的配置模板生成配置、根据数据库生成代码
        CodgenApplication.main(new String[] { "-i", "src/main/resources/in", "-o", "../" });
        // 再根据生成的mbgx配置生成MyBatis的代码
        MybatisGeneratorWrap.gen(Path.of("target", "mbgx"), true, null);
        // 最后根据解析java代码(Vo、Ctrl)生成其它的代码
        CodgenJavaApplication.main(new String[] {});
    }
}
