require 'javascript_integration_test'

class PageSidebarTest < JavascriptIntegrationTest
  include GroupRecords
  fixtures :users, :groups

  def setup
    super
    @user = users(:blue)
    own_page
    login
    click_on own_page.title
  end

  def test_sharing_with_user
    share_page_with users(:red)
    assert_page_users user, users(:red)
    wait_for_ajax # autocomplete queries might still be pending
  end

  def test_sharing_with_group
    share_page_with groups(:animals)
    assert_page_groups groups(:animals)
    wait_for_ajax # autocomplete queries might still be pending
  end

  def test_tagging
    tags = %w/some tags for this page/
    tag_page tags
    assert_page_tags tags
  end

end
