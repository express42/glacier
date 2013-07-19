action :backup do

  %w{git daemontools}.each do |pkg|
      package pkg
  end

  python_pip "git+git://github.com/uskudnik/amazon-glacier-cmd-interface.git"

  directory "/etc/glacier" do
    recursive true
    mode 0750
    owner "root"
    group "root"
  end

  directory new_resource.tempdir do
    recursive true
    mode 0750
    owner "root"
    group "root"
  end

  directory "/opt/chef/backups" do
    recursive true
    mode 0750
    owner "root"
    group "root"
  end

  directory "/etc/glacier/#{new_resource.name}" do
    recursive true
    mode 0750
    owner "root"
    group "root"
  end

  directory "/etc/glacier/#{new_resource.name}/env" do
    recursive true
    mode 0750
    owner "root"
    group "root"
  end

  template "/etc/glacier/#{new_resource.name}/glacier-cmd.conf" do
    mode 0640
    owner "root"
    group "root"
    source "glacier-cmd.conf.erb"
    cookbook "glacier"
    variables(
              :aws_key => new_resource.aws_key,
              :aws_secret => new_resource.aws_secret,
              :region => new_resource.region
             )
  end

  file "/etc/glacier/#{new_resource.name}/env/BACKUP_TEMPDIR" do
    mode 0640
    owner "root"
    group "root"
    content new_resource.tempdir
  end

  file "/etc/glacier/#{new_resource.name}/env/BACKUP_PATH" do
    mode 0640
    owner "root"
    group "root"
    content new_resource.path
  end

  file "/etc/glacier/#{new_resource.name}/env/BACKUP_GLACIER_VAULT" do
    mode 0640
    owner "root"
    group "root"
    content new_resource.vault
  end

  file "/etc/glacier/#{new_resource.name}/env/BACKUP_GLACIER_CONFIG" do
    mode 0640
    owner "root"
    group "root"
    content "/etc/glacier/#{new_resource.name}/glacier-cmd.conf"
  end

  file "/etc/glacier/#{new_resource.name}/env/BACKUP_TYPE" do
    mode 0640
    owner "root"
    group "root"
    content new_resource.full ? "Full" : "Incremental"
  end

  cookbook_file "/opt/chef/backups/glacier_backup_static.sh" do
    mode 0750
    owner "root"
    group "root"
    source "backup_script.sh"
    cookbook "glacier"
  end

  _new_resource = new_resource

  crontab "glacier #{_new_resource.name}" do
    command "/usr/bin/flock -n /tmp/glacier_backup_static_#{_new_resource.name}.lock /usr/bin/envdir /etc/glacier/#{_new_resource.name}/env /opt/chef/backups/glacier_backup_static.sh"
    minute _new_resource.time[:minute]
    hour _new_resource.time[:hour]
    day _new_resource.time[:day]
    month _new_resource.time[:month]
    weekday _new_resource.time[:weekday]
  end

end
