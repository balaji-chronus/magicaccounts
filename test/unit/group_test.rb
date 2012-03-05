require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end  

  test "valid group name between 6 and 32" do
    group = groups(:one)
    group.name = "AGS Group"
    
    group.save!
    assert group.valid?, "group shud be valid as 'AGS Group' is a valid name"
  end

  test "invalid group name less than 4 chars" do
    group = groups(:one)
    group.name = "baj"

    group.save
    assert !group.valid?, "group name less than 4 chars is not valid"
    assert_not_nil group.errors.get(:name), "group name less than 4 chars should raise an exception"
  end

  test "invalid group name greater than 32 chars" do
    group = groups(:one)
    group.name = "This is big group name that should fail validation"

    group.save
    assert !group.valid? , "group name more than 32 chars is not valid"
    assert_not_nil group.errors.get(:name), "group name more than 32 chars should raise an exception"
  end

  test "valid group name containing underscores hyphens apostrphes in between" do
    group = groups(:one)
    group.name = "b_-'j"
    
    group.save!
    assert group.valid?, "group shud be valid as 'b_-'j' is a valid name"
  end

  test "invalid group name doesnot start with an alphanumeric character" do
    group = groups(:one)
    group.name = "_baj"

    group.save
    assert !group.valid?, "group name not valid as name starts with a non alphanumeric character"
    assert_not_nil group.errors.get(:name), "group name starting with a non alphanumeric character should raise an exception"
  end

  test "invalid group name doesnot end with an alphanumeric character" do
    group = groups(:one)
    group.name = "baj_"

    group.save
    assert !group.valid?, "group name not valid as name ends with a non alphanumeric character"
    assert_not_nil group.errors.get(:name), "group name ending with a non alphanumeric character should raise an exception"
  end

  test "invalid group name contains unallowedspecial characters" do
    group = groups(:one)
    group.name = "ba#ju"

    group.save
    assert !group.valid?, "group name not valid as name contains unpermitted chars"
    assert_not_nil group.errors.get(:name), "group name containing unpermitted chars should raise an exception"
  end

  test "invalid group name is blank" do
    group = groups(:one)
    group.name = ""

    group.save
    assert !group.valid?, "group name not valid as name is empty"
    assert_not_nil group.errors.get(:name), "group name empty should raise an exception"
  end

  test "valid group status" do
    group = groups(:one)
    group.status = "Disabled"

    group.save!
    assert group.valid?, "group shud be valid as stats Disabled is a valid status"
  end

  test "invalid group status" do
    group = groups(:one)
    group.status = "New Status"

    group.save
    assert !group.valid?, "group status is not valid must be Enabled or Disabled"
    assert_not_nil group.errors.get(:status), "group status not Enabled or Disabled should raise an exception"
  end

  test "invalid group status empty" do
    group = groups(:one)
    group.status = ""

    group.save
    assert !group.valid?, "group status empty is not valid must be Enabled or Disabled"
    assert_not_nil group.errors.get(:status), "group status empty should raise an exception"
  end

  

  





end
