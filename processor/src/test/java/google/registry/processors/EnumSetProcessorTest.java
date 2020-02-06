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

import static com.google.common.truth.Truth.assertThat;
import static org.mockito.Mockito.when;

import javax.lang.model.element.Name;
import javax.lang.model.element.PackageElement;
import javax.lang.model.element.TypeElement;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

/**
 * Tests for the enum set annotation processor.
 *
 * <p>In fact, the full functionality of the processor is better tested in EnumSetUserTypeTest. This
 * just tests utility functions.
 */
@RunWith(JUnit4.class)
public class EnumSetProcessorTest {

  public EnumSetProcessorTest() {}

  @Rule public final MockitoRule mocks = MockitoJUnit.rule();

  @Mock Name packageName;
  @Mock Name className;
  @Mock Name outerClassName;
  @Mock PackageElement packageElem;
  @Mock TypeElement outerClassElem;
  @Mock TypeElement classElem;

  @Test
  public void testCreateNameInfo_flatName() {
    // Enclosing name is a package.
    when(classElem.getEnclosingElement()).thenReturn(packageElem);
    when(packageElem.getQualifiedName()).thenReturn(packageName);
    when(packageName.toString()).thenReturn("foo.bar.baz");
    when(classElem.getSimpleName()).thenReturn(className);
    when(className.toString()).thenReturn("Class");
    EnumSetProcessor.NameInfo nameInfo = EnumSetProcessor.createNameInfo(classElem);

    assertThat(nameInfo.getPackageName()).isEqualTo("foo.bar.baz");
    assertThat(nameInfo.getQualifiedClassName()).isEqualTo("Class");
    assertThat(nameInfo.getEncodedClassName()).isEqualTo("Class");
  }

  @Test
  public void testCreateNameInfo_nestedName() {
    // Enclosing name is a package.
    when(classElem.getEnclosingElement()).thenReturn(outerClassElem);
    when(outerClassElem.getEnclosingElement()).thenReturn(packageElem);
    when(packageElem.getQualifiedName()).thenReturn(packageName);
    when(packageName.toString()).thenReturn("foo.bar.baz");
    when(classElem.getSimpleName()).thenReturn(className);
    when(className.toString()).thenReturn("Class");
    when(outerClassElem.getSimpleName()).thenReturn(outerClassName);
    when(outerClassName.toString()).thenReturn("Outer");
    EnumSetProcessor.NameInfo nameInfo = EnumSetProcessor.createNameInfo(classElem);

    assertThat(nameInfo.getPackageName()).isEqualTo("foo.bar.baz");
    assertThat(nameInfo.getQualifiedClassName()).isEqualTo("Outer.Class");
    assertThat(nameInfo.getEncodedClassName()).isEqualTo("Outer_Class");
  }
}
