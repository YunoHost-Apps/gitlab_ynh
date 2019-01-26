external_url '__GENERATED_EXTERNAL_URL__'

gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main: # 'main' is the GitLab 'provider ID' of this LDAP server
    label: 'LDAP'
    host: 'localhost'
    port: 389
    uid: 'uid'
    encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
    bind_dn: ''
    password: ''
    active_directory: false
    allow_username_or_email_login: false
    block_auto_created_users: false
    base: 'ou=users,dc=yunohost,dc=org'
    user_filter: ''
EOS

nginx['listen_port'] = __PORT__
nginx['listen_https'] = false
nginx['listen_addresses'] = ["0.0.0.0", "[::]"] # listen on all IPv4 and IPv6 addresses

unicorn['port'] = __PORTUNICORN__

unicorn['worker_processes'] = 2
