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

package google.registry.persistence.converter;

import google.registry.persistence.VKey;
import java.util.Set;
import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

/** JPA {@link AttributeConverter} for storing/retrieving {@link Set<String>}. */
@Converter(autoApply = true)
public abstract class VKeySetConverter<T> extends StringSetConverterBase<VKey<T>> {

  @Override
  String toString(VKey<T> element) {
    return element.getSqlKey().toString();
  }

  @Override
  VKey<T> fromString(String value) {
    // TODO: this isn't correct, we don't know that the SQL key is necessarily a string.  It works
    // for HostResource, though.
    return VKey.createSql(getElementClass(), value);
  }

  protected abstract Class getElementClass();
}
