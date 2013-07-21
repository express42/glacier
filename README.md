Glacier Cookbook
======================

Install glacier-cmd utility and configure backups to glacier using glacier-cmd, tar and cron. It contains a LWRP for
describing glacier backups.

Requirements
------------

Tested only on Ubuntu 12.04, but should works on Debian too. Only works with [Express 42 crontab
cookbook](https://github.com/express42-cookbooks/crontab). You should remember to delete root's crontab entries when delete
glacier backups in chef.

LWRP
----

## glacier_static

glacier_static LWRP creates tasks for backuping static content. All cron tasks are belongs to root user.

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>backup</td>
    <td>Default action. Backups data.</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td><strong>Name attribute</strong>. Name of the backup (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>path</td>
    <td>Path to backup (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>time</td>
    <td>Describe time of backup, same format as for crontab (Hash)</td>
    <td>{ :minute => "0", :hour => "2", :day => "*", :month => "*", :weekday => "*" }</td>
  </tr>
  <tr>
    <td>tempdir</td>
    <td>Temporary backup dir</td>
    <td>/home/backups/</td>
  </tr>
  <tr>
    <td>aws_key</td>
    <td>AWS key (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>aws_secret</td>
    <td>AWS secret(required)</td>
    <td></td>
  </tr>
  <tr>
    <td>vault</td>
    <td>Glacier vault, should exists (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>region</td>
    <td>AWS region</td>
    <td>us-west-2</td>
  </tr>
  <tr>
    <td>full</td>
    <td>Incremental or full backup (boolean)</td>
    <td>false</td>
  </tr>
</table>

### Examples
```ruby
glacier_static "backup-daily" do
  path "/home/vagrant/"
  aws_key 'my aws key'
  aws_secret 'my aws secret'
  vault 'backup'
  time(:minute => "15", :hour => "4", :weekday => "1-6")
end

glacier_static "backup-weekly" do
  path "/home/vagrant/"
  aws_key 'my aws key'
  aws_secret 'my aws secret'
  vault 'backup'
  time(:minute => "15", :hour => "4", :weekday => "7")
  full true
end

```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author:: Ivan Evtuhovich <ivan@express42.com>

Copyright 2012-2013, Express 42, LLC
