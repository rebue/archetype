import java.util.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.NodeList;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.expr.AnnotationExpr;
import com.yomahub.liteflow.core.NodeComponent;

import io.github.codgen.java.ctx.CodeParserCtx;
import io.github.codgen.java.ctx.FileParserCtx;
import rebue.wheel.core.CaseFormatUtils;
import rebue.wheel.core.StrUtils;

/**
 * Ctrl类的代码解析器
 * 解析Ctrl类的代码，获取其中的类、方法、字段、注释等
 */
public class CtrlCodeParser extends NodeComponent {
    private static final Logger log = LoggerFactory.getLogger(CtrlCodeParser.class);

    @Override
    public void process() throws Exception {
        Map<String, Object>               bindings        = new HashMap<>();
        List<Map<String, Object>>         apis            = new LinkedList<>();
        FileParserCtx                     fileParserCtx   = this.getContextBean(FileParserCtx.class);
        CompilationUnit                   compilationUnit = fileParserCtx.getCompilationUnit();
        List<ClassOrInterfaceDeclaration> classes         = compilationUnit.findAll(ClassOrInterfaceDeclaration.class);
        ClassOrInterfaceDeclaration       clazz           = classes.getFirst();
        String                            className       = clazz.getName().asString();
        log.info("解析类：{}", className);
        String[]                classNameWords = CaseFormatUtils.splitCamel(className);
        String                  moduleName     = classNameWords[0].toLowerCase();
        String                  capModuleName  = StrUtils.capitalize(classNameWords[0]);
        String                  entityName     = String.join("", Arrays.copyOfRange(classNameWords, 1, classNameWords.length - 1));
        String                  entityDesc     = clazz.getJavadocComment().get().parse().getDescription().toText().replaceAll("的控制器", "的API接口");
        List<MethodDeclaration> methods        = clazz.getMethods();
        for (MethodDeclaration method : methods) {
            log.info("解析方法：{}", method.getNameAsString());
            String                   requestDesc = method.getJavadocComment().get().parse().getDescription().toText();
            NodeList<AnnotationExpr> annotations = method.getAnnotations();
            for (AnnotationExpr annotation : annotations) {
                log.info("解析注解：{}", annotation.getNameAsString());
                List<Node> childNodes = annotation.getChildNodes();
                if (childNodes.size() != 2) {
                    continue;
                }
                String requestMethod  = null;
                String annotationName = childNodes.getFirst().toString();
                if ("PostMapping".equals(annotationName)) {
                    requestMethod = "POST";
                } else if ("PutMapping".equals(annotationName)) {
                    requestMethod = "PUT";
                } else if ("DeleteMapping".equals(annotationName)) {
                    requestMethod = "DELETE";
                } else if ("GetMapping".equals(annotationName)) {
                    requestMethod = "GET";
                } else {
                    continue;
                }
                String requestName = method.getNameAsString();
                String uri         = childNodes.get(1).toString().replaceAll("\"", "");
                apis.add(Map.of("name", requestName, "desc", requestDesc, "method", requestMethod, "uri", uri));
                break;
            }
        }

        bindings.put("moduleName", moduleName);
        bindings.put("capModuleName", capModuleName);
        bindings.put("entityName", entityName);
        bindings.put("entityDesc", entityDesc);
        bindings.put("apis", apis);

        CodeParserCtx codeParserCtx = this.getContextBean(CodeParserCtx.class);
        codeParserCtx.setBindings(bindings);
    }
}