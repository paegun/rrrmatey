# RRRMatey

`rrrmatey` is an ODM (Object-Document-Mapper) framework for use with Basho Data
Platform (BDP) Cache Proxy and Riak KV.

CRUD operations are encapsulated at the controller- and model-level for relatively
smooth mixin for use in a `rails` or leaner `ruby` application framework.

BDP Cache Proxy provides the majority of the underlying interface to the data
layer. Redis acts as the cache layer while Riak provides availability with
partition tolerance. Riak Search is also used to provide the Index operation (the
silent I in CRUD).

## Dependencies

* Ruby
 * 1.9.3, 2.0, 2.1, and 2.2 are supported. JRuby in 1.9 and 2.0 modes are also
 supported.
* BDP Cache Proxy
 * Depends on write-around and read-through caching, so BDP EE 1.1.0+ .
* Riak KV
 * Depends on basic KV and Riak Search, so Riak KV v.2.0.0+ . Ensure Riak Search
 is enabled.

### Development Dependencies
Development dependencies are handled with bundler. Install bundler
(`gem install bundler`), if not present.

```shell
bundle install
```

### Tests
RSpec is generally run without coverage analysis.

```shell
rake spec
```

To enable coverage analysis, run with the 'CI' environment variable set.

```shell
CI=1 rake spec
```

## Use Cases

### Configuring Connections

Since `rrrmatey` uses BDP Cache Proxy which speaks a subset of the Redis protocol,
a `redis` client should be configured with  one or more host entries corresponding
to the BDP Cache Proxies.

Similarly, the `riak` client is used for Riak Search.

In both cases, the use of `connection_pool` is recommended.

The following example captures the essential elements of configuration. However,
for a Rails application, the connection details should be in environment-specific
files to avoid leaking production credentials.

```ruby
require 'rrrmatey'
require 'connection_pool'

RRRMatey::StringModel.cache_proxy = RRRMatey::Retryable.new(
    ConnectionPool.new(:size => 5, :timeout => 5) {
        Redis.new(:host => '127.0.0.1', :port => 22122)
    }   
)

RRRMatey::StringModel.riak = RRRMatey::Retryable.new(
    ConnectionPool.new(:size => 5, :timeout => 5) {
        Riak::Client.new(:nodes => [
            {:host => '127.0.0.1', :pb_port => 10017},
            {:host => '127.0.0.1', :pb_port => 10027},
            {:host => '127.0.0.1', :pb_port => 10037},
            {:host => '127.0.0.1', :pb_port => 10047},
            {:host => '127.0.0.1', :pb_port => 10057},
        ])  
    }   
)
```

### Developing Models with Relations

To provide a shipworthy example, the models for Pirate and Vessel including a
relation for aboard follows:

```ruby
class Pirate
    include ::RRRMatey::StringModel
    field :name, :type => :string
    field :created, :type => :date, :default => Date.new(1970, 1, 1)
    field :aboard, :type => :string

    def valid?
        valid_name? &&
            valid_created?
    end 

    private

    def valid_name?
        !name.blank?
    end 

    def valid_created?
    !created.nil? && created < Date.today - 14 * 365.25
    end 
end

class Vessel
    include ::RRRMatey::StringModel
    field :name, :type => :string

    def valid?
        valid_name?
    end 

    def boardings(offset, limit)
        Pirate.list_by(offset, limit, :aboard_s => vessel_id)
    end

    private

    def valid_name?
        !name.blank?
    end 
end
```

#### Specialiing the Model Connection
The module-level `riak` and `cache_proxy` connections may be overriden on the
Model-level.

#### Opinionated, but Open
The StringModel is opinionted, providing reasonable defaults for the following:
 * item_name
  * default: the class name in snake case format (underscored)
  * purpose: the element wrapper for json or xml content
 * index_name
  * default: the item_name
  * purpose: the Riak Search index name
  * note: the index is created automatically

Several Rails "built-in" methods such as blank? and underscore are used if
present or otherwise are monkey-patched in Rails fashion. This is mostly okey,
but Rails inflections, ie Person => People, are not re-implemented within
RRRMatey. For use in a Rails application, existing inflections will be used.
To be 100% covered, if a Model is known to be an abnormal case, requiring
inflection, specialize the item_name on the Model.

### Developing an API Controller

Using the Pirate and Vessel models and mixing in the CrudController requires
only definition of non-CRUD methods, ie "A Pirate boards a Vessel":

```ruby
class PiratesController < ApplicationController
    include RRRMatey::CrudController

    def board
        vessel_id = params['vessel_id']
        return respond_bad_request if vessel_id.blank?
        pirate_id = params['pirate_id']
        return respond_bad_request if pirate_id.blank?

        v = Vessel.get(vessel_id)
        return respond_not_found if v.nil?

        p = Pirate.get(pirate_id)
        return respond_not_found if p.nil?
        p.aboard = v.id
        p.save
        respond_ok(p)
    end 
end

class VesselsController < ApplicationController
    include RRRMatey::CrudController

    def boardings
        vessel_id = params['vessel_id']
        return respond_bad_request if vessel_id.blank?
        offset = params['offset'] || 0
        limit = params['limit'] || 20
        vessel = Vessel.new(vessel_id)
        pirates_aboard = vessel.boardings(offset, limit)
        respond_ok(pirates_aboard)
    end
end
```

#### Strong Parameters
By mixing in the CrudController functionality, existing Rails strong_parameters
best practice is still available within a Rails context and should be used.

## How to Contribute

* Fork the project on Github. If you have already forked, use `git pull --rebase`
to reapply your changes on top of the mainline. Example:

```shell
git checkout master
git pull --rebase basho master
```

* Create a topic branch. If you've already created a topic branch, rebase it on
top of changes from the mainline "master" branch. Examples:
 * New branch:

```shell
git checkout -b topic
```

 * Existing branch:

```shell
git rebase master
```

 * Write an RSpec example or set of examples that demonstrate the necessity and
 validity of your changes. **Patches without specs will most often be ignored.
 Just do it, you'll thank me later. Documenation patches need no specs, of course.

 * Make your feature addition or bug fix. Make your specs and stories pass (green).

 * Run the suite using multiruby or rvm or rbenv to ensure cross-version
 compatibility.

 * Cleanup any trailing whitespace in your code and generally follow the coding
 style of existing code.

 * Send a pull request to the upstream repositoty.

## License & Copyright
Copyright ©2015-2016 James Gorlick and Basho Technologies, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
