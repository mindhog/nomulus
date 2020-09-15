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

ALTER TABLE "PollMessage" DROP CONSTRAINT fk_poll_message_host_repo_id;
ALTER TABLE "HostHistory" DROP CONSTRAINT fk_hosthistory_hostresource;
ALTER TABLE "HostResource" DROP CONSTRAINT fk_host_resource_superordinate_domain;
ALTER TABLE "DomainHost" DROP CONSTRAINT fk_domainhost_host_valid;
ALTER TABLE "HostResource" DROP CONSTRAINT "HostResource_pkey";
DROP TABLE "HostResource";

CREATE TABLE "Host" (
   repo_id text not null,
    update_timestamp timestamptz,
    creation_registrar_id text not null,
    creation_time timestamptz not null,
    current_sponsor_registrar_id text not null,
    deletion_time timestamptz,
    last_epp_update_registrar_id text,
    last_epp_update_time timestamptz,
    statuses text[],
    host_name text,
    inet_addresses text[],
    last_superordinate_change timestamptz,
    last_transfer_time timestamptz,
    superordinate_domain text
);

ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT "Host_pkey" PRIMARY KEY (repo_id);
ALTER TABLE ONLY public."DomainHost"
    ADD CONSTRAINT fk_domainhost_host_valid FOREIGN KEY (host_repo_id) REFERENCES public."Host"(repo_id);
ALTER TABLE ONLY public."Host"
    ADD CONSTRAINT fk_host_superordinate_domain FOREIGN KEY (superordinate_domain) REFERENCES public."Domain"(repo_id);
ALTER TABLE ONLY public."HostHistory"
    ADD CONSTRAINT fk_hosthistory_host FOREIGN KEY (host_repo_id) REFERENCES public."Host"(repo_id);
ALTER TABLE ONLY public."PollMessage"
    ADD CONSTRAINT fk_poll_message_host_repo_id FOREIGN KEY (host_repo_id) REFERENCES public."Host"(repo_id);
