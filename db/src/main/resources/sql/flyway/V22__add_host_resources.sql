-- Copyright 2020 The Nomulus Authors. All Rights Reserved.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

create table "Domain_HostResource" (
   domain_repo_id text not null,
    hosts_repo_id text not null,
    primary key (domain_repo_id, hosts_repo_id)
);

create table "HostResource" (
   repo_id text not null,
    creation_client_id text,
    creation_time timestamptz,
    current_sponsor_client_id text,
    deletion_time timestamptz,
    last_epp_update_client_id text,
    last_epp_update_time timestamptz,
    statuses text[],
    fully_qualified_host_name text,
    last_superordinate_change timestamptz,
    last_transfer_time timestamptz,
    superordinate_domain bytea,
    primary key (repo_id)
);

create table "HostResource_inetAddresses" (
   host_resource_repo_id text not null,
    inet_addresses bytea
);

alter table if exists "Domain_HostResource"
   add constraint UK_m6ln9gnn74fbahsplrwbahrk9 unique (hosts_repo_id);

alter table if exists "Domain_HostResource"
   add constraint FK9d55iufjp85sn2v2nbtpadq66
   foreign key (hosts_repo_id)
   references "HostResource";

alter table if exists "Domain_HostResource"
   add constraint FKmh38qg6k98h4ro864q7nqarg2
   foreign key (domain_repo_id)
   references "Domain";

alter table if exists "HostResource_inetAddresses"
   add constraint FK6unwhfkcu3oq6q347fxvpagv
   foreign key (host_resource_repo_id)
   references "HostResource";

