// Copyright 2017 The Nomulus Authors. All Rights Reserved.
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

package google.registry.model;

import static google.registry.util.DateTimeUtils.START_OF_TIME;

import google.registry.model.translators.UpdateAutoTimestampTranslatorFactory;
import java.util.Optional;
import javax.annotation.Nullable;
import org.joda.time.DateTime;

/**
 * A timestamp that auto-updates on each save to Datastore.
 *
 * @see UpdateAutoTimestampTranslatorFactory
 */
public class UpdateAutoTimestamp extends ImmutableObject {

  // When set to true, database converters/translators should do tha auto update.  When set to
  // false, auto update should be suspended (this exists to allow us to preserve the original value
  // during a replay).
  static ThreadLocal<Boolean> autoUpdateEnabled = ThreadLocal.withInitial(() -> true);

  DateTime timestamp;

  /** Returns the timestamp, or {@code START_OF_TIME} if it's null. */
  public DateTime getTimestamp() {
    return Optional.ofNullable(timestamp).orElse(START_OF_TIME);
  }

  public static UpdateAutoTimestamp create(@Nullable DateTime timestamp) {
    UpdateAutoTimestamp instance = new UpdateAutoTimestamp();
    instance.timestamp = timestamp;
    return instance;
  }

  /** Class to allow us to safely disable auto-update in a try-with-resources block. */
  public static class DisableAutoUpdateResource implements AutoCloseable {
    DisableAutoUpdateResource() {
      autoUpdateEnabled.set(false);
    }

    @Override
    public void close() {
      autoUpdateEnabled.set(true);
    }
  }

  /**
   * Resturns a resource that disables auto-updates on all {@link UpdateAutoTimestamp}s in the
   * current thread, suitable for use with in a try-with-resources block.
   */
  public static DisableAutoUpdateResource disableAutoUpdate() {
    return new DisableAutoUpdateResource();
  }

  public static boolean autoUpdateEnabled() {
    return autoUpdateEnabled.get();
  }
}
