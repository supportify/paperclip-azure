= paperclip-azure

home  :: https://github.com/supportify/paperclip-azure
code  :: https://github.com/supportify/paperclip-azure
rdoc  :: http://www.rubydoc.info/github/supportify/paperclip-azure/master/
bugs  :: https://github.com/supportify/paperclip-azure/issues

== DESCRIPTION:

Paperclip-Azure is a [Paperclip](https://github.com/thoughtbot/paperclip) storage driver for storing files in a Microsoft Azure Blob.

== FEATURES/PROBLEMS:

* FIX (list of features or problems)

== SYNOPSIS:

The Azure storage engine has been developed to work as similarly to S3 storage configuration as is possible.  This gem can be configured in a Paperclip initializer or environment file as follows:

    Paperclip::Attachment.default_options[:storage] = :azure
    Paperclip::Attachment.default_options[:azure_credentials] = {
        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
        storage_access_key:   ENV['AZURE_STORAGE_ACCESS_KEY'],
        container:            ENV['AZURE_CONTAINER_NAME']
    }

Or, at the level of the model such as in the following example:

    has_attached_file :download,
                      storage: :azure,
                      azure_credentials: {
                        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
                        storage_access_key:   ENV['AZURE_STORAGE_ACCESS_KEY'],
                        container:            ENV['AZURE_CONTAINER_NAME']
                      }

Additionally, you can also supply credentials using a path or a File that contains the +storage_access_key+ and +storage_account_name+ that Azure gives you. You can 'environment-space' this just like you do to your `database.yml` file, so different environments can use different accounts:

    development:
      storage_account_name: foo
      storage_access_key: 123...
    test:
      storage_account_name: foo
      storage_access_key: abc...
    production:
      storage_account_name: foo
      storage_access_key: 456...

This is not required, however, and the file may simply look like this:

    storage_account_name: foo
    storage_access_key: 456...

In which case, those access keys will be used in all environments. You can also put your container name in this file, instead of adding it to the code directly. This is useful when you want the same account but a different container for development versus production.


=== Private Blob Access

In the even that are using a Blob that has been configured for Private access, you will need to use the Shared Access Signature functionality of Azure.  This functionality has been baked in to the `Attachment#expiring_url` method. Simply specify a time and a style and you will get a proper URL as follows:

    object.attachment.expiring_url(30.minutes.since, :thumb)

For more information about Azure Shared Access Signatures, please refer to [here](http://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-shared-access-signature-part-1/).

=== Azure Environments

Microsoft offers specialized Azure implementations for special circumstances should the need arise.  As of the most recent update of this gem, the AzureChinaCloud, AzureUSGovernment, and AzureGermanCloud environments all offer specific storage URL's that differ from those of the standard AzureCloud.  These regions can be specified via the `:region` key of the `:azure_credentials` dictionary by using the symbols `:cn`, `:usgovt`, and `:de` respectively.  When working with one of these environments, simply update your credentials to include the region as follows:

    Paperclip::Attachment.default_options[:azure_credentials] = {
        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
        storage_access_key:   ENV['AZURE_STORAGE_ACCESS_KEY'],
        container:            ENV['AZURE_CONTAINER_NAME'],
        region:               :de
    }

Or, in the instance where the credentials are specified at the model level:

    has_attached_file :download,
                      storage: :azure,
                      azure_credentials: {
                        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
                        storage_access_key:   ENV['AZURE_STORAGE_ACCESS_KEY'],
                        container:            ENV['AZURE_CONTAINER_NAME'],
                        region:               :cn
                      }

== REQUIREMENTS:

* An Azure storage account.

== INSTALL:

Add this line to your application's Gemfile after the Paperclip gem:

    gem 'paperclip-azure', '~> 1.0'

And then execute:

    $ bundle install

== DEVELOPERS:

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* After checking out the source, run:

      $ rake newb

  This task will install any missing dependencies, run the tests/specs, and generate the RDoc.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
* Submit a pull request for the finished product's integration.

== LICENSE:

(The MIT License)

Copyright (c) 2017 Supportify, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
