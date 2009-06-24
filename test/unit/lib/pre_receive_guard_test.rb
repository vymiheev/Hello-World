# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++


require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../../data/hooks/pre_receive_guard'

class PreReceiveGuardTest < ActiveSupport::TestCase
  context 'In general' do
    setup do
      @env = {
          'GITORIOUS_WRITABLE_BY_URL' => 'http://gitorious.example/repositories/writable_by?user=john',
          'SSH_ORIGINAL_COMMAND'  => 'git-receive-pack foo.git'}
      @guard = Gitorious::SSH::PreReceiveGuard.new(@env, "#{'0'*10} #{'fca'*10} refs/merge-requests/123")
    end
    
    should 'know if the hook is called via SSH and allow pushes if local' do
      assert !@guard.local_connection?
      @env.delete('SSH_ORIGINAL_COMMAND')
      @guard = Gitorious::SSH::PreReceiveGuard.new(@env, "#{'0'*10} #{'fca'*10} refs/merge-requests/123")
      assert @guard.local_connection?
      assert @guard.allow_push?
    end
    
    should 'build the correct authentication URL' do
      assert_equal "http://gitorious.example/repositories/writable_by?user=john&git_path=#{CGI.escape('refs/merge-requests/123')}", @guard.authentication_url
    end
    
    should 'extract the Git target correctly' do
      assert_equal 'refs/merge-requests/123', @guard.git_target
    end
    
    should 'not allow push when Gitorious says no' do
      @guard.stubs(:get_via_http).returns('false')
      assert !@guard.allow_push?
    end

    should 'not allow push when Gitorious says no' do
      @guard.stubs(:get_via_http).returns('true')
      assert @guard.allow_push?
    end
  end
end