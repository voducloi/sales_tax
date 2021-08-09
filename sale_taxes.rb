require 'csv'
def read_file(file_path)
  data = CSV.read(file_path)[1..-1]
  data
rescue
  []
end


class Item
  attr_accessor :quantity, :product, :price

  def initialize(*attributes)
    @quantity = attributes[0].to_i
    @product = attributes[1]
    @price = attributes[2].to_f
  end

  def to_s
    "#{ quantity }, #{ product }, %.2f" % price_taxed.round(2)
  end

  def imported?
    product.include?('imported')
  end

  def tax
    Taxer.new(self).tax
  end

  def total_price
    quantity * price
  end

  def price_taxed
    total_price + tax
  end
end

class Taxer
  attr_reader :item

  BASE_TAX = 0.1
  IMPORT_TAX = 0.05
  BOOKS = ['book'].freeze
  FOODS = ['chocolate'].freeze
  MEDICALS = ['pill'].freeze
  EXCLUDE = BOOKS + FOODS + MEDICALS

  def initialize(item)
    @item = item
  end

  def tax
    base_tax = exclude? ? 0 : BASE_TAX
    import_tax = item.imported? ? IMPORT_TAX : 0

    rounded_value(item.total_price * base_tax) + rounded_value(item.total_price * import_tax)
  end

  def exclude?
    EXCLUDE.any? { |e| item.product.include?(e) }
  end

  def rounded_value(value)
    (value * 20.0).ceil / 20.0
  end
end

def bill(datas)
  total = 0
  sales_tax = 0

  datas.each do |row|
    item = Item.new(*row)
    p item.to_s
    total += item.price_taxed
    sales_tax += item.tax
  end
  p "Sales Tax: %.2f" % sales_tax.round(2)
  p "Total: %.2f" % total.round(2)
end

data1 = read_file('./example_1.csv')
data2 = read_file('./example_2.csv')
data3 = read_file('./example_3.csv')

bill(data1)
p "==============="
bill(data2)
p "==============="
bill(data3)
p "==============="