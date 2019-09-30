// Copyright 2019 The Nomulus Authors. All Rights Reserved.
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

package google.registry.persistence;

import static com.google.common.base.Preconditions.checkState;
import static google.registry.config.RegistryConfig.getHibernateConnectionIsolation;
import static google.registry.config.RegistryConfig.getHibernateHikariConnectionTimeout;
import static google.registry.config.RegistryConfig.getHibernateHikariIdleTimeout;
import static google.registry.config.RegistryConfig.getHibernateHikariMaximumPoolSize;
import static google.registry.config.RegistryConfig.getHibernateHikariMinimumIdle;
import static google.registry.config.RegistryConfig.getHibernateLogSqlQueries;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;
import dagger.Module;
import dagger.Provides;
import google.registry.config.RegistryConfig.Config;
import google.registry.keyring.kms.KmsKeyring;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.HashMap;
import javax.inject.Qualifier;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import org.hibernate.boot.MetadataSources;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Environment;

/** Dagger module class for the persistence layer. */
@Module
public class PersistenceModule {
  // This name must be the same as the one defined in persistence.xml.
  public static final String PERSISTENCE_UNIT_NAME = "nomulus";
  public static final String HIKARI_CONNECTION_TIMEOUT = "hibernate.hikari.connectionTimeout";
  public static final String HIKARI_MINIMUM_IDLE = "hibernate.hikari.minimumIdle";
  public static final String HIKARI_MAXIMUM_POOL_SIZE = "hibernate.hikari.maximumPoolSize";
  public static final String HIKARI_IDLE_TIMEOUT = "hibernate.hikari.idleTimeout";

  @Provides
  @DefaultHibernateConfigs
  public static ImmutableMap<String, String> providesDefaultDatabaseConfigs() {
    ImmutableMap.Builder<String, String> properties = ImmutableMap.builder();

    properties.put(Environment.DRIVER, "org.postgresql.Driver");
    properties.put(
        Environment.CONNECTION_PROVIDER,
        "org.hibernate.hikaricp.internal.HikariCPConnectionProvider");
    // Whether to automatically validate and export schema DDL to the database when the
    // SessionFactory is created. Setting it to 'none' to turn off the feature.
    properties.put(Environment.HBM2DDL_AUTO, "none");

    properties.put(
        Environment.PHYSICAL_NAMING_STRATEGY, NomulusNamingStrategy.class.getCanonicalName());

    properties.put(Environment.ISOLATION, getHibernateConnectionIsolation());
    properties.put(Environment.SHOW_SQL, getHibernateLogSqlQueries());
    properties.put(HIKARI_CONNECTION_TIMEOUT, getHibernateHikariConnectionTimeout());
    properties.put(HIKARI_MINIMUM_IDLE, getHibernateHikariMinimumIdle());
    properties.put(HIKARI_MAXIMUM_POOL_SIZE, getHibernateHikariMaximumPoolSize());
    properties.put(HIKARI_IDLE_TIMEOUT, getHibernateHikariIdleTimeout());
    properties.put(Environment.DIALECT, NomulusPostgreSQLDialect.class.getName());
    return properties.build();
  }

  @Provides
  @AppEngineEmf
  public static EntityManagerFactory providesAppEngineEntityManagerFactory(
      @Config("cloudSqlJdbcUrl") String jdbcUrl,
      @Config("cloudSqlUsername") String username,
      @Config("cloudSqlInstanceConnectionName") String instanceConnectionName,
      KmsKeyring kmsKeyring,
      @DefaultHibernateConfigs ImmutableMap<String, String> defaultConfigs) {
    String password = kmsKeyring.getCloudSqlPassword();

    HashMap<String, String> overrides = Maps.newHashMap(defaultConfigs);
    // For Java users, the Cloud SQL JDBC Socket Factory can provide authenticated connections.
    // See https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory for details.
    overrides.put("socketFactory", "com.google.cloud.sql.postgres.SocketFactory");
    overrides.put("cloudSqlInstance", instanceConnectionName);

    EntityManagerFactory emf =
        create(jdbcUrl, username, password, ImmutableMap.copyOf(overrides), ImmutableList.of());
    Runtime.getRuntime().addShutdownHook(new Thread(emf::close));
    return emf;
  }

  /** Constructs the {@link EntityManagerFactory} instance. */
  @VisibleForTesting
  public static EntityManagerFactory create(
      String jdbcUrl,
      String username,
      String password,
      ImmutableMap<String, String> configs,
      ImmutableList<Class> annotatedClasses) {
    HashMap<String, String> properties = Maps.newHashMap(configs);
    properties.put(Environment.URL, jdbcUrl);
    properties.put(Environment.USER, username);
    properties.put(Environment.PASS, password);

    // If there are no annotated classes, we can create the EntityManagerFactory from the generic
    // method.  Otherwise we have to use a more tailored approach.
    EntityManagerFactory emf =
        annotatedClasses.isEmpty()
            ? Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME, properties)
            : createSpecializedEntityManagerFactory(properties, annotatedClasses);

    checkState(
        emf != null,
        "Persistence.createEntityManagerFactory() returns a null EntityManagerFactory");
    return emf;
  }

  static EntityManagerFactory createSpecializedEntityManagerFactory(
      HashMap<String, String> configs, ImmutableList<Class> annotatedClasses) {
    MetadataSources metadataSources =
        new MetadataSources(new StandardServiceRegistryBuilder().applySettings(configs).build());
    for (Class clazz : annotatedClasses) {
      metadataSources.addAnnotatedClass(clazz);
    }
    return metadataSources.buildMetadata().getSessionFactoryBuilder().build();
  }

  /** Dagger qualifier for the {@link EntityManagerFactory} used for App Engine application. */
  @Qualifier
  @Documented
  @Retention(RetentionPolicy.RUNTIME)
  public @interface AppEngineEmf {}

  /** Dagger qualifier for the default Hibernate configurations. */
  // TODO(shicong): Change annotations in this class to none public or put them in a top level
  //  package
  @Qualifier
  @Documented
  @Retention(RetentionPolicy.RUNTIME)
  public @interface DefaultHibernateConfigs {}
}
