require File.join File.dirname(__FILE__), 'appcfg'
run Rack::URLMap.new({
    '/' => AppCfg::App,
    '/error' => AppCfg::ErrorApp,
})
