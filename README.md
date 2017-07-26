# Greyscale Record

`GreyscaleRecord` is a flat-file ORM, designed for users whose data is perfectly static and is stored in a flat format (e.g. yaml files). It is a clone of [YamlBSides](https://github.com/gaorlov/yaml_b_sides), but is extended to support multiple backend drivers (YAML files, JSON APIs)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'greyscale_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install greyscale_record

## Usage

`Greyscale Record` acts very mich like active record. You set up your base class like you would an ActiveRecord class:

```ruby
class Person < GreyscaleRecord::Base
```

and your `#{FIXTURES_PATH}/people.yml` (see [Setup](#setup) for fixtures path setup):

```yml
greg:
  name: Greg Orlov
  url_slug: greg
  bio: |
    I do stuff

john:
  name: John Doe
  # ... etc
```

and you're in business. Your `Person` objects will now respond to the *present* fields as methods. (see [Properties](#property-definitions) for setting defaults)

Note: `Greyscale Record` expects your class names to match the fixture names (e.g. `Person` will want a `people.yml` file)

Your `Person` class now responds to 


### Indexing

* `index( field )` : will add an index on that field, for faster searching

### Property definitions

These are completely optional, but if you have a yaml file that's not uniform, and want to have some defaults, you can use

* `property( name, defaul= nil )` : will set a single field. will set defaul value to nil if omitted
* `properties( props = {})` : takes a hash; will set many defaults at once

### Associations

You can define simple associations that behave very much like ActiveRecord associations. Once you define your association, you will have a method with that name that will do the lookups and cache the results for you.

* `belongs_to association`: the base object has to have the association id
  * will return a single object or nil
* `has_one`: the assiociation object has the id of the base. 
  * will return a single object or nil
* `has_many`: the association object has the id of the base.
  * will return an array

#### Assocaition Options

Associations have some of the standard ActiveRecord options. Namely:
* `class`: specifies the class to find the record in.
  
  ```ruby
    has_one :special_thing, class: Thing
  ```

* `class_name`: specifies the class w.o having to have the class defined. Handy for circular dependencies
  
  ```ruby
    class Person < GreyscaleRecord::Base
      has_one :nickname, class_name: "Pesudonym"
    end

    class Pseudonym < GreyscaleRecord::Base
      belongs_to :bearer, class_name: "Person"
    end
  ```

* `through`: many to may association helper. 
  
  ```ruby
    class Person < GreyscaleRecord::Base
      has_many :person_foods
      has_many :favorite_foods, through: :person_foods, class_name: "Food"
    end

    class PersonFood < GreyscaleRecord::Base
      belongs_to :person
      belongs_to :food
    end

    class Food < GreyscaleRecord::Base
    end
  ```
  
  __NOTE__: only works for `has_one` and `has_many`

* `as`: specifies what the associated object calls the caller
  ```ruby
    class Person
      has_many :images, as: :target
    end

    class Image
      belongs_to :target, class: Person
    end
  ```
  __NOTE__: only works for `has_one` and `has_many`

* `polymorphic`: specifies a polymorphic `belongs_to` association. Better explanation [here, on the ActiveRecord page](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations)
  ```ruby
    class Person
      has_many :images, as: :target
    end

    class Party
      has_many :images, as: :target
    end

    class Image
      belongs_to :target, polymorphic: true
    end
  ```
  And then the `images.yml` looks something like
  ```yml
    image-1:
      thing_id: a
      thing_class: Person
      # ...
    image-2:
      thing_id: a
      thing_class: PArty
      #...
  ```

### Query Methods

* `all` : will give you all of the records in the table
* `first` : wil return the first record in the table
* `find( id )` : will find a single record with the specified yaml key
* `find_by( properties = {} )` : will find all the recored that match all the proerties in the hash

#### Relation methods

These act as you would expect them to in ActiveRecord. These can be chained and applied to associations
* `where( params )` : will return a relation which can be interacted with as if it were the resulting array
* `and( params )` : identical to `where`, but nicer to read

```ruby
  Person.where( url_slug: "greg" ) #=> [<Person>]
  Person.where( url_slug: "greg", name: "Greg Orlov" ).and( id: "greg") #=> [<Person>]
  Person.where( url_slug: "greg", name: "Greg Orlov" ).where( id: "greg") #=> [<Person>]
  # from the code above
  Person.first.images.where( some_property: "value" )
```

### Data Sourcing

As mentioned in the summary above, `GreyscaleRecord` can be connected to different data sources. The structure that we use is a `Driver`.
There is a built in driver to use as an example: Yaml Driver. This is the structure that controls data flow from the original data store,
such as YAML files or an API, and formats it to be consumed by the internal `GreyscaleRecord::DataStore::Store` object, which expects the
result set to look roughly like 

```
{ table_name: {
    record_id: { attribute: value, ... },
    ...
  },
  ...
}
```

`GreyscaleRecord` will populate the id field for you from the record keys.

### Data Patching

If you have a data set that you want to temporarily augment, you can apply a [JSON patch](http://jsonpatch.com/) to the data store.
This will apply the patch within the context of your current thread until it is removed

```ruby
    patch = ::Hana::Patch.new [ { 'op' => 'add', 'path' => '/people/mike', 'value' => { id: "mike", name: "Mike Uchman" } } ]

    # this will stick around indefinitely in this thread
    data_store.apply_patch patch

    Person.find( 'mike' ).name # => "Mike Uchman"
    Person.where( id: 'mike' ).first.name #=> "Mike Uchman"

    # let's go back to the original set
    data_store.remove_patch

    Person.where( id: "mike" ) #=> []
```

Or, if you are doing something simple and can fir your code in a single block, you can do:

```ruby
    data_store.with_patch patch do

      Person.find( 'mike' ).name # => "Mike Uchman"
      Person.where( id: 'mike' ).first.name #=> "Mike Uchman"

    end

    Person.where( id: "mike" ) #=> []
```

__NOTE__: The patch interface that `Store` expects is that of [Hana](https://github.com/tenderlove/hana). You don't have to use it, but it has
to respond to `patch.apply( doc )`. 


### Example

To use the `People` class from earlier, a fully fleshed out model would look something like:

```ruby
class Person < GreyscaleRecord::Base
  property   :name, ""
  properties url_slug: "",
             bio: ""

  has_many :nicknames

  index :name
  index :url_slug
end

class Nickname < GreyscaleRecord::Base
  belongs_to :person
end

```

and the YAML files will look like

```yml
# in people.yml
mark_twain:
  name: Mark Twain
  url_slug: mark-twain
  #...

# in nicknames.yml
sam_clemmens:
  name: Samuel Clemmens
  person_id: mark_twain
```


## Setup

The setup is pretty straightforward. Greyscale Record wants a logger and a base dir to look for files in. An example config for a Rails app would look like:

```ruby
GreyscaleRecord::logger = Rails.logger
# for now this is the only driver
GreyscaleRecord::Base.driver = GreyscaleRecord::Drivers::Yaml
GreyscaleRecord::Drivers::Yaml.root = Rails.root.join 'db', 'fixtures'


# in development.rb

# eanble reload of the data files to avoid having to restart the server for every change
GreyscaleRecord.live_reload = true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gaorlov/greyscale_record.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

