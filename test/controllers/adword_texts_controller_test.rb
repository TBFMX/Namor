require 'test_helper'

class AdwordTextsControllerTest < ActionController::TestCase
  setup do
    @adword_text = adword_texts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:adword_texts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create adword_text" do
    assert_difference('AdwordText.count') do
      post :create, adword_text: { ad_desc1: @adword_text.ad_desc1, ad_desc2: @adword_text.ad_desc2, ad_display: @adword_text.ad_display, ad_url: @adword_text.ad_url, adw_id: @adword_text.adw_id, group_id: @adword_text.group_id, name: @adword_text.name }
    end

    assert_redirected_to adword_text_path(assigns(:adword_text))
  end

  test "should show adword_text" do
    get :show, id: @adword_text
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @adword_text
    assert_response :success
  end

  test "should update adword_text" do
    patch :update, id: @adword_text, adword_text: { ad_desc1: @adword_text.ad_desc1, ad_desc2: @adword_text.ad_desc2, ad_display: @adword_text.ad_display, ad_url: @adword_text.ad_url, adw_id: @adword_text.adw_id, group_id: @adword_text.group_id, name: @adword_text.name }
    assert_redirected_to adword_text_path(assigns(:adword_text))
  end

  test "should destroy adword_text" do
    assert_difference('AdwordText.count', -1) do
      delete :destroy, id: @adword_text
    end

    assert_redirected_to adword_texts_path
  end
end
