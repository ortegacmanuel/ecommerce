require_relative "test_helper"

module Pricing
  class PricingTest < Test
    cover "Pricing*"

    def test_setting_price_updates_read_model
      product_1_id = SecureRandom.uuid
      run_command(
        ProductCatalog::RegisterProduct.new(
          product_id: product_1_id,
          name: "test"
        )
      )

      set_price(product_1_id, 20)
      assert_product_read_model_price(product_1_id, 20)
      set_price(product_1_id, 40)
      assert_product_read_model_price(product_1_id, 40)
    end

    def test_calculates_total_value
      product_1_id = SecureRandom.uuid
      run_command(
        ProductCatalog::RegisterProduct.new(
          product_id: product_1_id,
          name: "test"
        )
      )
      product_2_id = SecureRandom.uuid
      run_command(
        ProductCatalog::RegisterProduct.new(
          product_id: product_2_id,
          name: "test2"
        )
      )
      set_price(product_1_id, 20)
      set_price(product_2_id, 30)
      order_id = SecureRandom.uuid
      add_item(order_id, product_1_id)
      add_item(order_id, product_2_id)
      stream = "Pricing::Order$#{order_id}"
      assert_events(
        stream,
        OrderTotalValueCalculated.new(
          data: {
            order_id: order_id,
            discounted_amount: 50,
            total_amount: 50
          }
        )
      ) { calculate_total_value(order_id) }
    end

    def test_calculates_total_value_with_discount
      product_1_id = SecureRandom.uuid
      run_command(
        ProductCatalog::RegisterProduct.new(
          product_id: product_1_id,
          name: "test"
        )
      )
      set_price(product_1_id, 20)
      order_id = SecureRandom.uuid
      add_item(order_id, product_1_id)
      stream = "Pricing::Order$#{order_id}"
      assert_events(
        stream,
        OrderTotalValueCalculated.new(
          data: {
            order_id: order_id,
            discounted_amount: 20,
            total_amount: 20
          }
        )
      ) { run_command(CalculateTotalValue.new(order_id: order_id)) }
      assert_events(
        stream,
        OrderTotalValueCalculated.new(
          data: {
            order_id: order_id,
            discounted_amount: 18,
            total_amount: 20
          }
        )
      ) do
        run_command(
          Pricing::SetPercentageDiscount.new(order_id: order_id, amount: 10)
        )
      end
    end

    def test_setting_discounts_twice_not_possible_because_we_want_explicit_discount_change_command
      product_1_id = SecureRandom.uuid
      run_command(
        ProductCatalog::RegisterProduct.new(
          product_id: product_1_id,
          name: "test"
        )
      )
      set_price(product_1_id, 20)
      order_id = SecureRandom.uuid
      add_item(order_id, product_1_id)
      run_command(
        Pricing::SetPercentageDiscount.new(order_id: order_id, amount: 10)
      )
      assert_raises NotPossibleToAssignDiscountTwice do
        run_command(
          Pricing::SetPercentageDiscount.new(order_id: order_id, amount: 20)
        )
      end
    end

    private

    def assert_product_read_model_price(product_id, amount)
      assert_equal(amount, product_repository.find(product_id).price)
    end

    def set_price(product_id, amount)
      run_command(SetPrice.new(product_id: product_id, price: amount))
    end

    def add_item(order_id, product_id)
      run_command(
        AddItemToBasket.new(order_id: order_id, product_id: product_id)
      )
    end

    def calculate_total_value(order_id)
      run_command(CalculateTotalValue.new(order_id: order_id))
    end
  end
end
