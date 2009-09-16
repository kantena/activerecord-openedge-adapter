require 'test/unit'
['test_helper','models/office'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
class ValidationsTest < Test::Unit::TestCase

  def setup
    Office.delete_all
  end

  def test_external_id_must_be_present_and_unique
    office = Office.new
    assert_raise ActiveRecord::RecordInvalid do
      office.save!
    end
    assert_equal 2,office.errors.size
  end

end
