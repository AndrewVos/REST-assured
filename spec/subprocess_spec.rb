require 'tempfile'
require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/subprocess', __FILE__)

module RestAssured::Utils
  describe Subprocess do

    it 'forks passed block' do
      ppid_file = Tempfile.new('ppidfile')
      pid_file = Tempfile.new('pidfile')

      fork do
        pid_file.write(Process.pid)
        pid_file.rewind
        at_exit { exit! }
        Subprocess.new do
          ppid_file.write(Process.ppid)
          ppid_file.rewind
          sleep 2
        end
        sleep 0.5
      end
      Process.wait
      ppid_file.read.should == pid_file.read
    end

    it 'ensures no zombies' do
      Kernel.stub(:fork).and_return(pid = 1)
      Process.should_receive(:detach).with(pid)

      Subprocess.new {1}
    end

    it 'knows when it is running' do
      res_file = Tempfile.new('res')
      fork do
        at_exit { exit! }
        child = Subprocess.new { sleep 0.5 }
        res_file.write(child.alive?)
        res_file.rewind
      end
      Process.wait
      res_file.read.should == 'true'
    end

    context 'shuts down child process' do
      let(:child_pid) do
        Tempfile.new('child_pid')
      end

      let(:child_alive?) do
        begin
          Process.kill(0, child_pid.read.to_i)
          true
        rescue Errno::ESRCH
          false
        end
      end

      it 'when stopped' do
        child_pid

        fork do
          at_exit { exit! }
          child = Subprocess.new { sleep 2 }
          child_pid.write(child.pid)
          child_pid.rewind
          child.stop
        end
        Process.wait
        sleep 0.5
        child_alive?.should == false
      end

      it 'when exits normally' do
        if not running_in_spork?
          child_pid # Magic touch. Literally. Else Tempfile gets created in fork and that messes things up

          fork do
            at_exit { exit! }
            child = Subprocess.new { sleep 2 }
            child_pid.write(child.pid)
            child_pid.rewind
          end
          Process.wait
          sleep 0.5
          child_alive?.should == false
        else
          pending "Skipped: drb/spork breaks fork sandbox (at_exits are collected and fired all together on master process exit)"
        end
      end

      it 'when killed violently' do
        if not running_in_spork?
          child_pid

          fork do
            at_exit { exit! }
            child = Subprocess.new { sleep 2 }
            child_pid.write(child.pid)
            child_pid.rewind

            Process.kill('TERM', Process.pid)
          end

          sleep 0.5
          child_alive?.should == false
        else
          pending "Skipped: drb/spork breaks fork sandbox (at_exits are collected and fired all together on master process exit)"
        end
      end
    end
  end
end
