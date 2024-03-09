# About DUMMY application

This is a basic example of application using brest as a core for Code-Test-Document approach with a performance in mind.
It's purpose to cover all DSL features provided by brest.

# Setting up a dummy test application nuances

Skipped the Rails::TestUnitRailtie via  
```ruby
require "rails/test_unit/railtie"
``` 
Since it will be spamming empty generators message after tests executions.

# Data structure 
