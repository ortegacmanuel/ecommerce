module Infra
  module Types
    include Dry.Types
    UUID =
      Types::Strict::String.constrained(
        format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i
      )
    ID = Types::Strict::Integer
    Metadata =
      Types::Hash.schema(
        timestamp: Types::Params::DateTime.meta(omittable: true)
      )
    OrderNumber =
      Types::Strict::String.constrained(format: /\A\d{4}\/\d{2}\/\d+\z/i)
    Price = Types::Coercible::Decimal.constrained(gt: 0)
    Value = Types::Coercible::Decimal
    PercentageDiscount = Types::Coercible::Decimal.constrained(gt: 0, lt: 100)
  end
end
