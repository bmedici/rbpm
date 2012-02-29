class Run < ActiveRecord::Base
  belongs_to :step
  has_many :actions
end