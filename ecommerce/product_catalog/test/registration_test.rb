require_relative "test_helper"

module ProductCatalog
  class RegistrationTest < Test
    cover "ProductCatalog*"

    def test_product_should_get_registered
      uid = SecureRandom.uuid
      register_product(uid, fake_name)
      refute_nil(product_registered = product_repository.find(uid))
      assert_equal(product_registered.name, fake_name)
    end

    def test_should_not_allow_for_double_registration
      uid = SecureRandom.uuid
      assert_raises(Product::AlreadyRegistered) do
        register_product(uid, fake_name)
        register_product(uid, fake_name)
      end
    end

    private

    def register_product(uid, name)
      run_command(RegisterProduct.new(product_id: uid, name: name))
    end

    def fake_name
      "Fake name"
    end
  end
end
