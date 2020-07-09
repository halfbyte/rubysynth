require 'synth_blocks'

#
# Manual Clap
#

SFREQ = 44100

filter = SynthBlocks::Core::StateVariableFilter.new(SFREQ)
env = SynthBlocks::Mod::Envelope.new(0.001, 0.02)
times = [[0, 1], [0.02, 0.8], [0.03, 0.6], [0.045, 0.4]]
out = SFREQ.times.map do |i|
  t  = i.to_f / SFREQ.to_f
  out = rand() * 2 - 1
  all_envs = 0
  times.each {|et| all_envs += env.run(t-et[0]) * et[1] if (t >= et[0])  }
  all_envs = [all_envs, 1].min
  ffreq = 100 + (2000 * all_envs)
  out = filter.run(out, ffreq, 4) * all_envs
  out *= 0.5
end

SynthBlocks::Core::WaveWriter.write_if_name_given(out)