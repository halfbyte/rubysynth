SAMPLES = %w[pitch_env_drum waveshaper noise lowpass_filtered highpass_filtered amp_env filter_env pitch_env manual_snare snare_only]

desc "update examples"
task :update_examples => SAMPLES.map {|sample| "website/samples/#{sample}.wav"}

SAMPLES.each do |sample|
  file "website/samples/#{sample}.wav" => ["examples/#{sample}.rb"] do |t|
    sh "bundle exec ruby #{t.prerequisites.first} #{t.name}"
  end
end

task :compile_opal => ['website/js/opal.js']

file 'website/js/opal.js' => ['examples/opal_loader.rb'] do |t|
  sh "bundle exec opal -g synth_blocks --compile #{t.prerequisites.first} >#{t.name}"
end