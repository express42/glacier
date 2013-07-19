default_action :backup
actions :backup

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :path, :kind_of => String, :required => true
attribute :time, :kind_of => Hash, :default => { :minute => "0", :hour => "2", :day => "*", :month => "*", :weekday => "*" }
attribute :tempdir, :kind_of => String, :default => "/home/backups/"
attribute :aws_key, :kind_of => String, :required => true
attribute :aws_secret, :kind_of => String, :required => true
attribute :vault, :kind_of => String, :required => true
attribute :region, :kind_of => String, :default => "us-west-2"
attribute :full, :equal_to => [false, true], :required => false, :default => false
