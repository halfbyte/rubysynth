
desc "update examples"
task :update_examples => FileList['website/samples/*.wav']

# For now, explicitly list files, so that we don't need to autogen all long running demos each time

file 'website/samples/waveshaper.wav' => ['examples/waveshaper_demo.rb'] do |t|
  sh "bundle exec ruby #{t.prerequisites.first} #{t.name}"
end


task :compile_opal => ['website/js/opal.js']

file 'website/js/opal.js' => ['examples/opal_loader.rb'] do |t|
  sh "bundle exec opal -g synth_blocks --compile #{t.prerequisites.first} >#{t.name}"
end