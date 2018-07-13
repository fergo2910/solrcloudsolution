#
# Cookbook Name:: solrcloud
# Library:: solrcloud
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

# SolrCloud Helper Module
module SolrCloud
  # SolrCloud Zookeeper Helper
  class Zk
    attr_accessor :zkconn

    def initialize(server)
      # server => 'zkhost:zkport'
      @zkconn = ZK.new(server)
    end

    def collection?(collection)
      clusterstate = zkconn.get('/clusterstate.json').first
      if clusterstate
        return JSON.parse(clusterstate).map { |k, _v| k }.include?(collection)
      else
        return false
      end
    end

    def collections
      JSON.parse(zkconn.get('/clusterstate.json').first).map { |k, _v| k }
    end

    def configset?(configset)
      zkconn.exists?("/configs/#{configset}") # zkconn.exists?("/configs/#{configset}/solrconfig.xml") and zkconn.exists?("/configs/#{configset}/schema.xml")
    end

    def delete_configset(configset)
      zkconn.delete("/configs/#{configset}") # if zkconn.exists?("/configs/#{configset}")
    end
  end

  # Solrcloud API Helper
  class SolrEntity
    attr_accessor :httpconn, :headers

    def initialize(opts = {})
      # opts = {
      #   :host [String] => 'solr host',
      #   :port [String] => 'solr host port',
      #   :ssl_port [String] => 'solr host port',
      #   :use_ssl [Boolean]=> 'use https instead',
      # }
      @options    = opts
      @headers    = {
        'Accept' => 'application/json',
        'Keep-Alive' => '120',
        'Content-Type' => 'application/json'
      }
      connect(opts[:host], opts[:port], opts[:ssl_port], opts[:use_ssl])
    end

    def connect(host, port, ssl_port, use_ssl = false)
      host_port = use_ssl ? ssl_port : port
      begin
        TCPSocket.new(host, host_port)
      rescue => error
        raise "solr service port is down or inaccessible #{host}:#{host_port}, #{error.class} - #{error.message}"
      end
      Chef::Log.info("connecting to solr host=#{host} on ssl port=#{host_port}")
      @httpconn = Net::HTTP.new host, host_port
      if use_ssl
        @httpconn.use_ssl = true
        @httpconn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  # Solr Collection Management Class
  class Collection < SolrEntity
    def create(name, replication_factor, opts)
      # name [String] => 'collection name'
      # replication_factor [String, Integer] => 'collection replication factor'
      # opts = {
      #   :context_path [String] => 'solr context path',
      #   :num_shards [String, Integer] => 'number of shards',
      #   :shards [String] => 'shards',
      #   :max_shards_per_node [String, Integer] => 'maximum shards allowed per cluster node',
      #   :create_node_set [Boolean] => 'whether create node set',
      #   :collection_config_name [String] => 'collection zookeeper config set name to use',
      #   :router_name [string] => 'router name',
      #   :router_field [String] => 'router field id',
      #   :async [Boolean] => 'set async',
      #   :auto_add_replicas [Boolean] => 'auto add replica'
      # }
      Chef::Log.info("collection #{name} creating ..")
      # Required Parameters
      # Not necessary, but keeping it clean
      context_path = opts[:context_path] == '/' ? '' : opts[:context_path]
      url = "#{context_path}/admin/collections?wt=json&action=CREATE&name=#{name}&replicationFactor=#{replication_factor}"
      # Optional Parameters
      url << "&numShards=#{opts[:num_shards]}" if opts[:num_shards]
      url << "&shards=#{opts[:shards]}" if opts[:shards]
      url << "&maxShardsPerNode=#{opts[:max_shards_per_node]}" if opts[:max_shards_per_node]
      url << "&createNodeSet=#{opts[:create_node_set]}" if opts[:create_node_set]
      url << "&collection.configName=#{opts[:collection_config_name]}" if opts[:collection_config_name]
      url << "&router.name=#{opts[:router_name]}" if opts[:router_name]
      url << "&router.field=#{opts[:router_field]}" if opts[:router_field]
      url << "&async=#{opts[:async]}" if opts[:async]
      url << "&autoAddReplicas=#{opts[:auto_add_replicas]}" if opts[:auto_add_replicas]
      reply = httpconn.request(Net::HTTP::Post.new(url, headers))
      data  = JSON.pretty_generate(JSON.parse(reply.body))

      if reply.code.to_i == 200
        Chef::Log.info("collection #{name} created. => #{data}")
        return true
      else
        fail "#{url}, collection #{name} failed to create. => #{data}"
      end
    end

    def delete(name, context_path)
      Chef::Log.info("collection #{name} deleting ..")
      # Not necessary, but keeping it clean
      context_path = context_path == '/' ? '' : context_path
      url = "#{context_path}/admin/collections?wt=json&action=DELETE&name=#{name}"
      reply = httpconn.request(Net::HTTP::Post.new(url, headers))
      data = JSON.pretty_generate(JSON.parse(reply.body))
      if reply.code.to_i == 200
        Chef::Log.info("collection #{name} deleted. => #{data}")
        return true
      else
        fail "#{url}, collection #{name} failed to delete. => #{data}"
      end
    end

    def reload(name, context_path)
      Chef::Log.info("collection #{name} reloading ..")
      # Not necessary, but keeping it clean
      context_path = context_path == '/' ? '' : context_path
      url = "#{context_path}/admin/collections?wt=json&action=RELOAD&name=#{name}"
      reply = httpconn.request(Net::HTTP::Post.new(url, headers))
      data = JSON.pretty_generate(JSON.parse(reply.body))
      if reply.code.to_i == 200
        Chef::Log.info("collection #{name} reloaded. => #{data}")
        return true
      else
        fail "#{url}, collection #{name} failed to reload. => #{data}"
      end
    end
  end
end
