# Setting up a dummy test application nuances

Skipped the Rails::TestUnitRailtie via  
```ruby
require "rails/test_unit/railtie"
``` 
Since it will be spamming empty generators message after tests executions.