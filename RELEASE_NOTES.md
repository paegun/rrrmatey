# RRRMatey Release Notes

## 0.1.0 Release - 2016-01-04

Version 0.1.0 is released as a reference for how to use the BDP Cache Proxy
and Riak KV to implement an API.

### New Features:
* StringModel mixin integrating BDP Cache Proxy and Riak Search to support all
 CRUD operations.
* CrudController mixin supporting all CRUD operations, requiring only non-CRUD
 operations to be added.

### Significant Known Issues

Several Rails "built-in" methods such as blank? and underscore are used if
present or otherwise are monkey-patched in Rails fashion. This is mostly okey,
but Rails inflections, ie Person => People, are not re-implemented within
RRRMatey. For use in a Rails application, existing inflections will be used.
To be 100% covered, if a Model is known to be an abnormal case, requiring
inflection, specialize the item_name on the Model.

The Update method on CrudController does not operate in a PATCHy way, merging the
existing values from the underlying data store with the values provided via the PUT
method. Implementing PATCH seemed to conflate understanding of the use of BDP
Cache Proxy and Riak Search.
