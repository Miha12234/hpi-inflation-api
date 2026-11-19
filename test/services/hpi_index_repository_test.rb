require "test_helper"

class HpiIndexRepositoryTest < ActiveSupport::TestCase
  test "the supplied CSV has the raw indices used in the worked example" do
    repository = HpiIndexRepository.default

    assert_equal BigDecimal("28.25136458"), repository.index_for("Islington", "2000-01")
    assert_equal BigDecimal("103.597769"), repository.index_for("Islington", "2016-01")
    assert_equal "Oxford", repository.canonical_area(" OXFORD ")
  end
end
