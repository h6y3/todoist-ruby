# Todoist Ruby

This is an unofficial client library that interfaces with the [Todoist API](https://developer.todoist.com/sync/v8/).  

## What's implemented

### Sync API

The "sync" API is almost fully implemented with the exception of collaboration features.  

* [Projects](https://developer.todoist.com/sync/v8/#projects)
* [Templates](https://developer.todoist.com/sync/v8/#templates)
* [Items](https://developer.todoist.com/sync/v8/#items)
* [Labels](https://developer.todoist.com/sync/v8/#labels)
* [Notes](https://developer.todoist.com/sync/v8/#notes)
* [Filters](https://developer.todoist.com/sync/v8/#filters)
* [Reminders](https://developer.todoist.com/sync/v8/#reminders)

### Other APIs

* [Miscellaneous](https://developer.todoist.com/sync/v8/#miscellaneous)
* [Quick](https://developer.todoist.com/sync/v8/#quick)
* [Activity](https://developer.todoist.com/sync/v8/#activity)
* [Uploads](https://developer.todoist.com/sync/v8/#uploads)
* [Backups](https://developer.todoist.com/sync/v8/#backups)

In addition to the above mentioned APIs, there is also an implementation of the "query" method call provided (with limitations documented).

## What's not implemented

Generally speaking collaboration features are not supported through this API but contributions are welcome and encouraged primarily due to testing limitations and the requirement to have multiple accounts.  This includes:

* [Emails](https://developer.todoist.com/sync/v8/#emails)
* [User](https://developer.todoist.com/sync/v8/#user)
* [Sharing](https://developer.todoist.com/sync/v8/#sharing)
* [Live notifications](https://developer.todoist.com/sync/v8/#live-notifications)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'todoist-ruby'
```

or install from source

```ruby
gem "todoist-ruby", :git => "git://github.com/h6y3/todoist-ruby.git"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install todoist-ruby

## Usage

This section provides some simple scenarios to get started.  To use the library make sure you include the library as follows:

```ruby
require 'todoist'
```

### Logging in and setting tokens

Before you make any API calls, you **must** create a client using one of two methods.  The library supports two methods:

#### Email and password

```ruby
@client = Todoist::Client.create_client_by_login("hello@example.com", "123")
```

#### Token

New tokens can be generated at the [Todoist App Management portal](https://developer.todoist.com/appconsole.html) or [General API token](https://todoist.com/prefs/integrations).  Once a token has been acquired you can create a client by calling:

```ruby
@client = Todoist::Client.create_client_by_token("my token")
```

### Using the API

The Todoist API enables you to mimic how the actual Todoist client retrieves information.  Among other nuances, the "sync" API minimizes network traffic by batching a series of calls together.  It supports dependencies between as-yet-created objects through temporary IDs.  In addition to the sync API, Todoist also has several other methods that are lighterweight.  For many light use cases, the lightweight methods will suffice but for more complex cases you will likely need to use both approaches.

All APIs can be accessed through the client.  In general, the naming convention to access the service is ```[api_type]_[api]```.

There are two ways to force a sync in the API:

1.  ```collection```:  Calling collection forces the library to sync with the Todoist server to retrieve the latest.  This method stores an internal in-memory copy of the result for incremental syncs but the caller should store a copy of the result in its own variable for query purposes.  The following call syncs all items and returns a collection of the items:  ```@client.sync_items.collection```.
2.  ```sync```: Calling the sync method on the client object forces a sync which can be called like ```@client.sync```

When objects are called using the ```add``` methods, a shallow object is created with a temporary id accessible by sending an ```id``` message.  Once any of the above synchronization methods are called above, the ids are updated via a callback with their actual ids so they can be used in subsequent calls.

#### Creating an item

```ruby
update_item = @client.sync_items.add({content: "Item3"})     
## At this time update_item has a temporary id

update_item.priority = 2
result = @client.sync_items.update(update_item)
# Up until this point update_item has not been created yet

items_list =  @client.sync_items.collection
# Update item is created and a query is issued to sync up the existing items.  The actual id of the newly created item is updated and so now update_item should have the actual id.

queried_object = items_list[update_item.id]
# update_item remains a shallow value object.  To fully inflate the object, you will need to retrieve the item from the list.  At this point, queried_object has a fully inflated copy of the object

@client.sync_items.delete([update_item])
# As is the case with other side-effects, issuing the call does not send the request immediately.  

@client.sync     
# Manually calling sync deletes the item
```

For more detailed examples, please review the unit tests located in the ```spec``` directory.

### Other APIs

The rest of the APIs are available in the ```Todoist::Misc``` module.  For lighterweight use cases, there are several interesting APIs of interest.  See Todoist documentation linked above.

#### Creating an item using the "quick" API

```ruby
item = @client.misc_quick.add_item("Test quick add content today")
# Unlike the sync API the item is already created after this method call and fully inflated
```
### Rate limiting

According to the Todoist API documentation, the following limitations exist:

  The maximum number of commands is 100 per request, and this is done to prevent timeouts and other problems when dealing with big requests.

  There’s also a maximum number of 50 sync requests per minute for each user, in order to prevent clients from accidentally overloading our servers.

In practice, the rate limit is much more aggressive than 50 sync requests per minute as far as I can tell.  Because of this, the unit tests make use of [vcr](https://github.com/vcr/vcr) to cache HTTP requests.  While it is unlikely clients will hit the rate limit besides unit test scenarios, it can be possible.

The library provides two defenses against this.

#### HTTP 429 Protection
If an ```HTTP 429 Too Many Requests``` is received, the library can wait for a period of time and then retry with an exponential backoff.  To configure this parameter:

```ruby
Todoist::Config.retry_time = 40
# Default is 20s, adds a 40s delay
```

#### Delay between sync requests

To set an artifical delay between sync requests:

```ruby
Todoist::Config.delay_between_requests = 2
# Default is 0, adds a 2s delay
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.  You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run the unit tests, a development token is needed and should be stored on the first line of a file located at ```spec/token```.

Due to rate limiting, running ```rake``` will result in HTTP 429 codes.  Instead, it is recommended that tests be run individually for the area that you wish to develop:

```
rspec spec/misc_items_spec.rb
```

The unit tests generate a set of 100 UUIDs for both temporary ids and command_uuids.  This is done so that when the VCR gem records the user interaction, the HTTP requests match.  When there are bugs in the test that propogate to problematic network calls, you will need to clean both the generated UUIDs and the VCR recordings.  To do this, a rake command is provided:

```
rake spec:clean["misc_items"]
# Cleans up VCR and UUIDs for artifacts with the "misc_items" prefix
```

Once tests pass cleanly, subsquent runs that do not change the network requests run quickly since no network calls are made and in fact ```rake``` can be run with no issues.


## Migration

### Migrating from 1.x to 2.x

2.x was a major rewrite of the library that avoids using classes as Singletons.  In addition, in 2.x the client facing interfaces have been greatly simplified.

### Authentication

Instead of:
```
Todoist::Config.token = "my token"
```

Use:

```
@client = Todoist::Client.create_client_by_token("my token")
```

### Calling Services

Instead of:

```
@manager = Todoist::Sync::Items.new
@manager.collection
```

Use:
```
@client.sync_items.collection
```

### Synchronization

Instead of:

```
Todoist::Util::CommandSynchronizer.sync
```

Use:

```
@client.sync
```


## Version History
* 0.2.4: Numerous bug fixes to address v7 to v8 changes that go beyond just an endpoint change.  Passing all specs.
* 0.2.3: Updated to v8 endpoints
* 0.2.2: For some code paths, it seems OpenSSL does not get loaded.  Added require 'openssl' to network helper
* 0.2.1: Major refactoring of library to support implementations that require multi-user support in a concurrent environment (e.g. Rails app).  The previous implementation relied heavily on class singletons.  Internally, the code has been cleaned up significantly.  Due to the scale of changes, 0.2.1 is not compatible 0.1.x versions of the library.
* 0.1.3: Changed ```Todoist::Sync``` managers so that the update method uses a hash instead of an OpenStruct.  The OpenStruct creates errors when an OpenStruct passed from a previous call is used.  The hash helps the caller make fewer mistakes.
* 0.1.2: Renamed method ```Todoist::Util::ParseHelper.make_objects_as_array``` to ```Todoist::Util::ParseHelper.make_objects_as_hash``` to reflect the fact that it was actually returning hashes.  Added the aforementioned deleted method to return arrays and finally altered ```Todoist::Misc::Completed``` to return objects as arrays instead of hashes due to the fact that recurring completed items were being de-duped unintentionally and data was being lost as a result.
* 0.1.1: Initial release.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/h6y3/todoist-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
