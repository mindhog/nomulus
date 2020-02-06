// Copyright 2020 The Nomulus Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package google.registry.processors;

import static java.nio.charset.StandardCharsets.UTF_8;

import com.google.auto.value.AutoValue;
import com.google.common.annotations.VisibleForTesting;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.Set;
import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Filer;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.PackageElement;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;

/** Processor for the EnumSet annotation. */
@SupportedAnnotationTypes("google.registry.persistence.EnumSet")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class EnumSetProcessor extends AbstractProcessor {
  @Override
  public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
    for (TypeElement annotation : annotations) {
      for (Element element : roundEnv.getElementsAnnotatedWith(annotation)) {
        if (element instanceof TypeElement) {
          NameInfo nameInfo = createNameInfo(element);
          String packageName = nameInfo.getPackageName();
          String encodedClassName = nameInfo.getEncodedClassName();
          String qualifiedClassName = nameInfo.getQualifiedClassName();

          // Generate the corresponding SetType class.
          Filer filer = processingEnv.getFiler();
          try (PrintWriter out =
              new PrintWriter(
                  new OutputStreamWriter(
                      filer
                          .createSourceFile(
                              packageName + "." + encodedClassName + "SetType", element)
                          .openOutputStream(),
                      UTF_8))) {
            out.format(
                "package %s;\n"
                    + "import google.registry.persistence.EnumSetUserType;\n"
                    + "public class %sSetType extends EnumSetUserType<%s> {\n"
                    + "  @Override\n"
                    + "  protected %s convertToElem(String value) {\n"
                    + "    return %s.valueOf(value);"
                    + "  }\n"
                    + "}\n",
                packageName,
                encodedClassName,
                qualifiedClassName,
                qualifiedClassName,
                qualifiedClassName);
          } catch (IOException e) {
            throw new RuntimeException(e);
          }
          processingEnv
              .getMessager()
              .printMessage(Diagnostic.Kind.NOTE, "Found @EnumSet at " + element);
        }
      }
    }
    return false;
  }

  /** A tuple of package name, encoded class name and qualified class name. */
  @VisibleForTesting
  @AutoValue
  abstract static class NameInfo {
    static NameInfo create(String packageName, String encodedClassName, String qualifiedClassName) {
      return new AutoValue_EnumSetProcessor_NameInfo(
          packageName, encodedClassName, qualifiedClassName);
    }

    abstract String getPackageName();

    /**
     * The class name prefixed by the names of its enclosing classes, but excluding enclosing
     * packages.
     *
     * <p>For example, if the original class was Baz nested in Bar nested in Foo (i.e.
     * "Foo.Bar.Baz") the encoded class name would be Foo_Bar_Baz.
     */
    abstract String getEncodedClassName();

    abstract String getQualifiedClassName();

    /** Returns a new NameInfo with 'name' appended to the existing class name. */
    NameInfo withClass(String name) {
      return create(
          getPackageName(),
          getEncodedClassName() + "_" + name,
          getQualifiedClassName() + "." + name);
    }
  }

  /** Returns the package name and qualified class name for an element (see NameInfo above). */
  @VisibleForTesting
  static NameInfo createNameInfo(Element element) {
    Element enclosing = element.getEnclosingElement();
    if (enclosing instanceof TypeElement) {
      return createNameInfo(enclosing).withClass(element.getSimpleName().toString());
    } else if (enclosing instanceof PackageElement) {
      return NameInfo.create(
          ((PackageElement) enclosing).getQualifiedName().toString(),
          element.getSimpleName().toString(),
          element.getSimpleName().toString());
    } else {
      throw new AssertionError("Unexpected enclosing type in EnumSet annotation: " + enclosing);
    }
  }
}
