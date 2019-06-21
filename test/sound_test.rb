require 'test_helper'
require_relative '../lib/sound'

class SoundWithDuration < Sound
  def duration(_)
    1
  end
end

class SoundWithRelease < Sound
  def release(_)
    0.5
  end
end

class TestSound < Minitest::Test
  SFREQ = 44100
  def test_simple_set
    sound = Sound.new(SFREQ)
    vol = 0.2
    sound.set(:volume, 0, vol)
    assert_equal vol, sound.get(:volume, 1)
  end

  def test_two_sets
    sound = Sound.new(SFREQ)
    vol = 0.2
    sound.set(:volume, 0, 0)
    sound.set(:volume, 1, vol)
    assert_equal vol, sound.get(:volume, 2)
  end

  def test_linear_automation
    sound = Sound.new(SFREQ)
    vol = 3
    sound.set(:volume, 0, 0)
    sound.automate(:volume, :linear, 3, vol)
    sound.set(:volume, 5, 0)
    assert_equal 1, sound.get(:volume, 1)
    assert_equal 2, sound.get(:volume, 2)
    assert_equal 3, sound.get(:volume, 3)
    assert_equal 3, sound.get(:volume, 4)
    assert_equal 0, sound.get(:volume, 5)
  end

  def test_monophonic_events
    sound = SoundWithRelease.new(SFREQ, mode: :monophonic)
    sound.start(1)
    sound.stop(3)
    sound.start(4, 36)
    sound.start(5, 48)
    sound.stop(6, 48)
    sound.stop(7, 36)
    assert_equal(
      { 36 => {started: 1, velocity: 1.0 } },
      sound.active_events(1)
    )
    assert_equal(
      { 36 => {started: 1, velocity: 1.0 } },
      sound.active_events(2)
    )
    assert_equal(
      { 36 => {started: 1, velocity: 1.0, stopped: 3 } },
      sound.active_events(3)
    )
    assert_equal(
      {},
      sound.active_events(3.5)
    )
    assert_equal(
      { 36 => {started: 4, velocity: 1.0 } },
      sound.active_events(4)
    )
    assert_equal(
      { 48 => {started: 5, velocity: 1.0 } },
      sound.active_events(5)
    )
    assert_equal(
      { 36 => {started: 4, velocity: 1.0 } },
      sound.active_events(6)
    )
    assert_equal(
      { 36 => {started: 4, velocity: 1.0, stopped: 7 } },
      sound.active_events(7)
    )
    assert_equal(
      {},
      sound.active_events(8)
    )
  end

  def test_polyphonic_events_with_release
    sound = SoundWithRelease.new(SFREQ, mode: :polyphonic)
    sound.mode = :polyphonic
    sound.start(1, 40)
    sound.start(2, 35)
    sound.stop(3, 40)
    sound.stop(4, 35)

    assert_equal({
      40 => {started: 1, velocity: 1.0}
    }, sound.active_events(1))
    assert_equal({
      40 => {started: 1, velocity: 1.0},
      35 => {started: 2, velocity: 1.0}
    }, sound.active_events(2))
    assert_equal({
      40 => {started: 1, velocity: 1.0, stopped: 3},
      35 => {started: 2, velocity: 1.0}
    }, sound.active_events(3))
    assert_equal({
      35 => {started: 2, velocity: 1.0, stopped: 4}
    }, sound.active_events(4))
    assert_equal({
      35 => {started: 2, velocity: 1.0, stopped: 4}
    }, sound.active_events(4.2))
    assert_equal({}, sound.active_events(4.5))
  end
  def test_polyphonic_events_with_duration
    sound = SoundWithDuration.new(SFREQ, mode: :polyphonic)
    sound.mode = :polyphonic
    sound.start(1, 40)
    sound.start(2, 35)

    assert_equal({
      40 => {started: 1, velocity: 1.0}
    }, sound.active_events(1))
    assert_equal({
      40 => {started: 1, velocity: 1.0},
    }, sound.active_events(1.5))
    assert_equal({
      35 => {started: 2, velocity: 1.0},
    }, sound.active_events(2))
    assert_equal({}, sound.active_events(3))
  end

end
