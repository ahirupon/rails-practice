require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  test 'layouts test' do
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    get contact_path
    assert_select 'title', full_title("Contact")
  end
  #   assert true
  # end
end

# assert_select "div"	<div>foobar</div>
# assert_select "div", "foobar"	<div>foobar</div>
# assert_select "div.nav"	<div class="nav">foobar</div>
# assert_select "div#profile"	<div id="profile">foobar</div>
# assert_select "div[name=yo]"	<div name="yo">hey</div>
# assert_select "a[href=?]", ’/’, count: 1	<a href="/">foo</a>
# assert_select "a[href=?]", ’/’, text: "foo"	<a href="/">foo</a>