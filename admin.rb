def add_user(p4port = nil, user = nil, email = nil, password = nil)
  p4port ||= prompt 'p4port', ENV['P4PORT']
  user ||= prompt 'username'
  email ||= prompt 'email'
  password ||= prompt 'password'

  form  = "User: #{user}" + '\n\n'
  form += "Email: #{email}" + '\n\n'
  form += "Password: #{password}" + '\n\n'
  form += "FullName: #{user}" + '\n\n'

  puts "Creating user: #{user}"
  puts %x[echo "#{form}" | p4 -p #{p4port} user -i -f]

  form  = "Client: #{client_name user}" + '\n\n'
  form += "Owner: #{user}" + '\n\n'
  form += "Description:" + '\n'
  form += '\t' + "Created by #{user}" + '\n\n'
  form += "Root: #{working_copy user}" + '\n\n'
  form += "Options: noallwrite noclobber nocompress unlocked nomodtime normdir" + '\n\n'
  form += "SubmitOptions: submitunchanged" + '\n\n'
  form += "LineEnd: local" + '\n\n'
  form += "View:" + '\n\n'
  form += '\t' + "//depot/app-config-app/... //#{client_name user}/..." + '\n\n'

  puts "Creating client: #{client_name user}"
  puts %x[echo "#{form}" | p4 -p #{p4port} -u #{user} -P #{password} client -i]

  if !Dir.exists? working_copy user
    puts "Creating folder for working copy: #{working_copy user}"
    puts %x[mkdir -p #{working_copy user}]
  end

  puts "Synchronizing working copy..."
  puts %x[p4 -p #{p4port} -u #{user} -P #{password} -c #{client_name user} sync]
end

def map_changes(p4port = nil, user = nil, password = nil, new_env = nil, source_env = nil)
  p4port ||= prompt 'p4port', ENV['P4PORT']
  user ||= prompt 'username'
  password ||= prompt 'password'
  new_env ||= prompt 'new environment'
  source_env ||= prompt 'source environment'

  form  = "Branch: #{source_env}-#{new_env}" + '\n\n'
  form += "Owner: #{user}" + '\n\n'
  form += "Options: unlocked" + '\n\n'
  form += "View:" + '\n\n'
  form += '\t' + "//depot/app-config-app/#{source_env}... //depot/app-config-app/#{new_env}..." + '\n\n'

  puts "Creating change mapping #{source_env}-#{new_env}..."
  puts %x[echo "#{form}" | p4 -p #{p4port} -u #{user} -P #{password} -c #{user}Client branch -i]
  puts %x[p4 -p #{p4port} -u #{user} -P #{password} -c #{user}Client integrate -b #{source_env}-#{new_env}]
  puts %x[p4 -p #{p4port} -u #{user} -P #{password} -c #{user}Client submit -d "(admin.rb) Created change mapping from #{source_env} to #{new_env}"]
end

def client_name(user)
  "#{user}Client"
end

def prompt(message, default = nil)
  $stdout.write message
  $stdout.write ' [' + default + ']' if default
  $stdout.write ': '
  input = $stdin.readline.strip
  input.length > 0 ? input : default
end

def working_copy(user)
  File.join (File.expand_path File.dirname __FILE__), 'wc', user
end
