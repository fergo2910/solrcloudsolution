#
# Cookbook Name:: solrcloud
# Recipe:: zkconfigsets
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

node['solrcloud']['zkconfigsets'].each do |configset_name, options|
  solrcloud_zkconfigset configset_name do
    user options['user']
    group options['group']
    zkcli options['zkcli']
    zkhost options['zkhost']
    zkconfigsets_home options['zkconfigsets_home']
    zkconfigsets_cookbook options['zkconfigsets_cookbook']
    manage_zkconfigsets options['manage_zkconfigsets']
    solr_zkcli options['solr_zkcli']
    force_upload options['force_upload']
    action options['action']
  end
end
