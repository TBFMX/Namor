require 'test_helper'

class AdGroupsControllerTest < ActionController::TestCase
  setup do
    @ad_group = ad_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ad_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ad_group" do
    assert_difference('AdGroup.count') do
      post :create, ad_group: { amount: @ad_group.amount, campaing_id: @ad_group.campaing_id, gr_id: @ad_group.gr_id, name: @ad_group.name }
    end

    assert_redirected_to ad_group_path(assigns(:ad_group))
  end

  test "should show ad_group" do
    get :show, id: @ad_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ad_group
    assert_response :success
  end

  test "should update ad_group" do
    patch :update, id: @ad_group, ad_group: { amount: @ad_group.amount, campaing_id: @ad_group.campaing_id, gr_id: @ad_group.gr_id, name: @ad_group.name }
    assert_redirected_to ad_group_path(assigns(:ad_group))
  end

  test "should destroy ad_group" do
    assert_difference('AdGroup.count', -1) do
      delete :destroy, id: @ad_group
    end

    assert_redirected_to ad_groups_path
  end
end
