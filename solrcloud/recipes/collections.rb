#
# Cookbook Name:: solrcloud
# Recipe:: collections
#
# Copyright 2014, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['solrcloud']['collections'].each do |collection_name, options|
  collection_name = options['name'] if options['name']

  solrcloud_collection collection_name do
    num_shards options['num_shards']
    context_path options['context_path']
    shards options['shards']
    router_field options['router_field']
    async options['async']
    router_name options['router_name']
    use_ssl options['use_ssl']
    host options['host']
    auto_add_replicas options['auto_add_replicas']
    port options['port']
    ssl_port options['ssl_port']
    create_node_set options['create_node_set']
    replication_factor options['replication_factor']
    max_shards_per_node options['max_shards_per_node']
    collection_config_name options['collection_config_name']
    zkcli options['zkcli']
    zkhost options['zkhost']
    action options['action']
  end
end
