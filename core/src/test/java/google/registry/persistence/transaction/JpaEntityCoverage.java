// Copyright 2018 The Nomulus Authors. All Rights Reserved.
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

package google.registry.persistence.transaction;

import static com.google.common.base.Preconditions.checkState;
import static google.registry.persistence.transaction.TransactionManagerFactory.jpaTm;

import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import google.registry.persistence.PersistenceXmlUtility;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.persistence.Entity;
import org.junit.rules.ExternalResource;

/**
 * Checks for JPA {@link Entity entities} that are declared in persistence.xml but not persisted in
 * integration tests.
 */
public class JpaEntityCoverage extends ExternalResource {

  // TODO(weiminyu): update this set when entities written to Cloud SQL and tests are added.
  private static final ImmutableSet<String> IGNORE_ENTITIES =
      ImmutableSet.of(
          "DelegationSignerData",
          "DesignatedContact",
          "GracePeriod",
          "RegistrarContact",
          // HostResources gets covered in the DomainBase tests which haven't been ported to this
          // branch.
          "HostResource");

  private static final ImmutableSet<Class> ALL_JPA_ENTITIES =
      PersistenceXmlUtility.getManagedClasses().stream()
          .filter(e -> !IGNORE_ENTITIES.contains(e.getSimpleName()))
          .filter(e -> e.getAnnotation(Entity.class) != null)
          .collect(ImmutableSet.toImmutableSet());
  private static final Set<Class> allCoveredJpaEntities = Sets.newHashSet();
  // Map of test class name to boolean flag indicating if it tests any JPA entities.
  private static final Map<String, Boolean> testsJpaEntities = Maps.newHashMap();

  // Provides class name of the test being executed.
  private final TestCaseWatcher watcher;

  public JpaEntityCoverage(TestCaseWatcher watcher) {
    this.watcher = watcher;
  }

  @Override
  public void before() {
    testsJpaEntities.putIfAbsent(watcher.getTestClass(), false);
  }

  @Override
  public void after() {
    ALL_JPA_ENTITIES.stream()
        .filter(JpaEntityCoverage::isPersisted)
        .forEach(
            entity -> {
              allCoveredJpaEntities.add(entity);
              testsJpaEntities.put(watcher.getTestClass(), true);
            });
  }

  public static void init() {
    allCoveredJpaEntities.clear();
    testsJpaEntities.clear();
  }

  public static Set<Class> getUncoveredEntities() {
    return Sets.difference(ALL_JPA_ENTITIES, allCoveredJpaEntities);
  }

  public static ImmutableList<String> getIrrelevantTestClasses() {
    return testsJpaEntities.entrySet().stream()
        .filter(e -> !e.getValue())
        .map(Map.Entry::getKey)
        .collect(ImmutableList.toImmutableList());
  }

  /**
   * Checks if at least one instance of {@code entityType} has been persisted during the test, and
   * if yes, reads one of them back. If the read is successful, there is no incompatibility between
   * server and schema regarding type.
   *
   * @return true if an instance of {@code entityType} is found in the database and can be read
   */
  private static boolean isPersisted(Class entityType) {
    try {
      List result =
          jpaTm()
              .transact(
                  () ->
                      jpaTm()
                          .getEntityManager()
                          .createQuery(
                              String.format("SELECT e FROM %s e", getJpaEntityName(entityType)),
                              entityType)
                          .setMaxResults(1)
                          .getResultList());
      return !result.isEmpty() && entityType.isInstance(result.get(0));
    } catch (RuntimeException e) {
      // See if this was caused by a "relation does not exist" error.
      Throwable cause = e;
      while ((cause = cause.getCause()) != null) {
        if (cause instanceof SQLException
            && cause.getMessage().matches("(?s).*relation .* does not exist.*")) {
          throw new RuntimeException(
              "SQLException occurred.  If you've updated the set of entities, make sure you've "
                  + "also updated the golden schema.  See db/README.md for details.",
              e);
        }
      }

      throw e;
    }
  }

  private static String getJpaEntityName(Class entityType) {
    Entity entityAnnotation = (Entity) entityType.getAnnotation(Entity.class);
    checkState(
        entityAnnotation != null, "Unexpected non-entity type %s", entityType.getSimpleName());
    return Strings.isNullOrEmpty(entityAnnotation.name())
        ? entityType.getSimpleName()
        : entityAnnotation.name();
  }
}
