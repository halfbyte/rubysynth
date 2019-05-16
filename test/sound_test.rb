require 'test_helper'
require_relative '../lib/sound'

class TestSound < Minitest::Test
  def test_simple_set
    sound = Sound.new
    vol = 0.2
    sound.set(:volume, 0, vol)
    assert_equal vol, sound.get(:volume, 1)
  end

  def test_two_sets
    sound = Sound.new
    vol = 0.2
    sound.set(:volume, 0, 0)
    sound.set(:volume, 1, vol)
    assert_equal vol, sound.get(:volume, 2)
  end

  def test_linear_automation
    sound = Sound.new
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
    sound = Sound.new
    sound.mode = :monophonic
    sound.start(1)
    sound.stop(3)
    sound.start(4)
    sound.start(5)
    sound.stop(6)
    assert_equal [{started: 1, note: 36, velocity: 127 }], sound.active_events(2)
    assert_equal [{started: 1, note: 36, velocity: 127, stopped: 3}], sound.active_events(3)
    assert_equal [
      {started: 1, note: 36, velocity: 127, stopped: 3},
      {started: 4, note: 36, velocity: 127},
    ], sound.active_events(4)
    assert_equal [
      {started: 1, note: 36, velocity: 127, stopped: 3},
      {started: 4, note: 36, velocity: 127, stopped: 5},
      {started: 5, note: 36, velocity: 127},
    ], sound.active_events(5)
    assert_equal [
      {started: 1, note: 36, velocity: 127, stopped: 3},
      {started: 4, note: 36, velocity: 127, stopped: 5},
      {started: 5, note: 36, velocity: 127, stopped: 6},
    ], sound.active_events(6)
  end

  def test_polyphonic_events
    sound = Sound.new
    sound.mode = :polyphonic
    sound.start(1, note: 40)
    sound.start(2, note: 35)
    sound.stop(3, note: 40)
    sound.stop(4, note: 35)
    assert_equal [{started: 1, note: 40, velocity: 127}], sound.active_events(1)
    assert_equal [
      {started: 1, note: 40, velocity: 127},
      {started: 2, note: 35, velocity: 127},
    ], sound.active_events(2)
    assert_equal [
      {started: 1, note: 40, velocity: 127, stopped: 3},
      {started: 2, note: 35, velocity: 127},
    ], sound.active_events(3)
    assert_equal [
      {started: 1, note: 40, velocity: 127, stopped: 3},
      {started: 2, note: 35, velocity: 127, stopped: 4},
    ], sound.active_events(4)
  end

end
