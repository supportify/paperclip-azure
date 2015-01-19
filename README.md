# paperclip-azure

Paperclip-Azure is a [Paperclip](https://github.com/thoughtbot/paperclip) storage driver for storing files in a Microsoft Azure Blob.

## Installation

Add this line to your application's Gemfile after the Paperclip gem:

    gem 'paperclip-optimizer'

And then execute:

    $ bundle

## Usage

The Azure storage engine has been developed to work as similarly to S3 storage configuration as is possible.  This gem can be configured in a Paperclip initializer as follows:

    Paperclip::Attachment.default_options[:storage] = :azure
    Paperclip::Attachment.default_options[:url] = ':azure_path_url'
    Paperclip::Attachment.default_options[:path] = ":class/:attachment/:id/:style/:filename"
    Paperclip::Attachment.default_options[:storage] = :azure
    Paperclip::Attachment.default_options[:azure_credentials] = {
        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
        access_key:           ENV['AZURE_ACCESS_KEY'],
        container:            ENV['AZURE_CONTAINER_NAME']
    }

Or, at the level of the model such as in the following example:

    has_attached_file :download, 
                      storage: :azure,
                      azure_credentials: {
                        storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
                        access_key:           ENV['AZURE_ACCESS_KEY'],
                        container:            ENV['AZURE_CONTAINER_NAME']
                      }


## Private Blob Access

In the even that are using a Blob that has been configured for Private access, you will need to use the Shared Access Signature functionality of Azure.  This functionality has been baked in to the `Attachment#expiring_url` method. Simply specify a time and a style and you will get a proper URL as follows:

    object.attachment.expiring_url(30.minutes.since, :thumb)

For more information about Azure Shared Access Signatures, please refer to [here](http://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-shared-access-signature-part-1/).

## Contributing to paperclip-azure
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
* Submit a pull request for the finished product's integration.

## Copyright

Copyright (c) 2015. See [LICENSE](LICENSE.txt) for
further details.

