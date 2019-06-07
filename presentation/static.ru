use Rack::Static, urls: ['/samples', '/images', '/js', '/css']
app = proc do |env|
  if env['PATH_INFO'] == '' || env['PATH_INFO'] == '/'
    [302, {'Location' => 'index.html'}, ['Redirect']]
  else
    file_path = File.basename(env['PATH_INFO'])
    if File.exist?(file_path)
      [200, {'Content-Type' => 'text/html'}, File.open(file_path, File::RDONLY)]
    else
      [404, {'Content-Type' => 'text/plain'}, ['Not Found']]
    end
  end
end
run app
